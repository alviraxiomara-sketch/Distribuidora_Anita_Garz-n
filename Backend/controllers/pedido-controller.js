import { supabase } from "../config/supabase.js";
import { enviarCorreoPedidoExitoso } from "../services/notificacion-service.js";

// ==========================
// MODELOS AUXILIARES
// ==========================
const crearPedido = async (pedido) => {
    const { data, error } = await supabase
        .from("pedidos")
        .insert([pedido])
        .select()
        .single();
    return { data, error };
};

const crearDetallePedido = async (detalle) => {
    const { data, error } = await supabase
        .from("detalle_pedido")
        .insert([detalle])
        .select()
        .single();
    return { data, error };
};

const obtenerPedidosPorUsuario = async (id_usuario) => {
    return await supabase
        .from("pedidos")
        .select("*, detalle_pedido(*, productos(*))")
        .eq("id_usuario", id_usuario)
        .order("created_at", { ascending: false });
};

const obtenerTodosLosPedidos = async () => {
    return await supabase
        .from("pedidos")
        .select("*, usuarios(nombre, correo), detalle_pedido(*, productos(*))")
        .order("created_at", { ascending: false });
};

const obtenerPedidoPorId = async (id_pedido) => {
    return await supabase
        .from("pedidos")
        .select("*, usuarios(nombre, correo), detalle_pedido(*, productos(*))")
        .eq("id_pedido", id_pedido)
        .maybeSingle();
};

const actualizarEstadoPedido = async (id_pedido, estado) => {
    return await supabase
        .from("pedidos")
        .update({ estado })
        .eq("id_pedido", id_pedido)
        .select()
        .single();
};

// ==========================
// CREAR PEDIDO
// ==========================
export const crear = async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { direccion_entrega, telefono_contacto, metodo_pago, comprobante_url } = req.body;

        // VALIDAR DATOS
        if (!direccion_entrega) {
            return res.status(400).json({ error: "La dirección de entrega es obligatoria" });
        }

        if (!telefono_contacto) {
            return res.status(400).json({ error: "El teléfono de contacto es obligatorio" });
        }

        // OBTENER CARRITO
        const { data: carrito, error: errorCarrito } = await supabase
            .from("carrito")
            .select(`
                id_carrito,
                detalle_carrito (
                    id_detalle_carrito,
                    id_producto,
                    cantidad,
                    precio_unitario,
                    subtotal
                )
            `)
            .eq("id_usuario", id_usuario)
            .maybeSingle();

        if (errorCarrito) {
            return res.status(500).json({ error: errorCarrito.message });
        }

        if (!carrito || !carrito.detalle_carrito || carrito.detalle_carrito.length === 0) {
            return res.status(400).json({ error: "El carrito está vacío" });
        }

        // VERIFICAR PRODUCTOS Y STOCK
        let total = 0;
        const detallesValidados = [];
        const resumenProductos = [];

        for (const detalle of carrito.detalle_carrito) {
            const { data: producto, error: errorProducto } = await supabase
                .from("productos")
                .select(`
                    id_producto,
                    nombre,
                    precio_detal,
                    precio_mayorista,
                    cantidad_minima_mayorista,
                    activo
                `)
                .eq("id_producto", detalle.id_producto)
                .maybeSingle();

            if (errorProducto || !producto) {
                return res.status(404).json({ error: `El producto ${detalle.id_producto} no existe` });
            }

            if (!producto.activo) {
                return res.status(400).json({ error: `El producto "${producto.nombre}" ya no está disponible` });
            }

            // OBTENER INVENTARIO
            const { data: inventario, error: errorInventario } = await supabase
                .from("inventario")
                .select(`id_inventario, stock_actual`)
                .eq("id_producto", detalle.id_producto)
                .maybeSingle();

            if (errorInventario || !inventario) {
                return res.status(400).json({ error: `El producto "${producto.nombre}" no tiene inventario disponible` });
            }

            if (Number(detalle.cantidad) > Number(inventario.stock_actual)) {
                return res.status(400).json({ error: `Stock insuficiente para "${producto.nombre}". Disponible: ${inventario.stock_actual}` });
            }

            let precioUnitario = Number(producto.precio_detal);

            if (
                producto.precio_mayorista &&
                producto.cantidad_minima_mayorista &&
                Number(detalle.cantidad) >= Number(producto.cantidad_minima_mayorista)
            ) {
                precioUnitario = Number(producto.precio_mayorista);
            }

            const subtotal = Number(detalle.cantidad) * precioUnitario;
            total += subtotal;

            detallesValidados.push({
                id_producto: detalle.id_producto,
                cantidad: Number(detalle.cantidad),
                precio_unitario: precioUnitario,
                subtotal
            });

            resumenProductos.push(`${producto.nombre} (x${detalle.cantidad})`);
        }

        // CREAR PEDIDO
        const pedido = {
            id_usuario,
            direccion_entrega,
            telefono_contacto,
            estado: "PENDIENTE",
            total
        };

        const { data: nuevoPedido, error: errorPedido } = await crearPedido(pedido);

        if (errorPedido) {
            return res.status(500).json({ error: errorPedido.message });
        }

        // REGISTRAR EN LA TABLA 'pagos'
        const { error: errorPago } = await supabase
            .from("pagos")
            .insert([{
                id_pedido: nuevoPedido.id_pedido,
                metodo_pago: metodo_pago || "Nequi",
                valor: total,
                estado: "PENDIENTE",
                comprobante: comprobante_url || null,
                fecha_pago: new Date()
            }]);

        if (errorPago) {
            console.error("Error al registrar pago:", errorPago.message);
        }

        // CREAR DETALLES DEL PEDIDO
        for (const detalle of detallesValidados) {
            await crearDetallePedido({
                id_pedido: nuevoPedido.id_pedido,
                id_producto: detalle.id_producto,
                cantidad: detalle.cantidad,
                precio_unitario: detalle.precio_unitario,
                subtotal: detalle.subtotal
            });
        }

        // DESCONTAR INVENTARIO
        for (const detalle of detallesValidados) {
            const { data: inventario } = await supabase
                .from("inventario")
                .select(`id_inventario, stock_actual`)
                .eq("id_producto", detalle.id_producto)
                .single();

            const nuevoStock = Number(inventario.stock_actual) - Number(detalle.cantidad);

            await supabase
                .from("inventario")
                .update({ stock_actual: nuevoStock, updated_at: new Date() })
                .eq("id_inventario", inventario.id_inventario);

            await supabase
                .from("movimientos_inventario")
                .insert({
                    id_producto: detalle.id_producto,
                    tipo_movimiento: "SALIDA",
                    cantidad: detalle.cantidad,
                    observacion: `Salida por pedido #${nuevoPedido.id_pedido}`,
                    id_usuario
                });
        }

        // VACIAR CARRITO
        await supabase
            .from("detalle_carrito")
            .delete()
            .eq("id_carrito", carrito.id_carrito);

        // ==========================
        // NOTIFICACIONES
        // ==========================

        // 1. Notificación para el cliente
        await supabase.from("notificaciones").insert([{
            id_usuario: id_usuario,
            titulo: "¡Pedido Realizado!",
            mensaje: `Tu pedido #${nuevoPedido.id_pedido} ha sido registrado con éxito por $${total}.`,
            leida: false
        }]);

        // 2. Notificación para los administradores con DETALLE DE PRODUCTOS Y COMPROBANTE
        const { data: adminUsers } = await supabase
            .from("usuarios")
            .select("id_usuario")
            .or("rol.eq.ADMIN,rol.eq.admin");

        const mensajeDetalladoAdmin = `Cliente: ${req.usuario.nombre}\nCompra: ${resumenProductos.join(', ')}\nTotal: $${total}`;

        if (adminUsers && adminUsers.length > 0) {
            for (const admin of adminUsers) {
                await supabase.from("notificaciones").insert([{
                    id_usuario: admin.id_usuario,
                    titulo: "Nuevo Pedido Recibido",
                    mensaje: mensajeDetalladoAdmin,
                    comprobante: comprobante_url || null,
                    leida: false
                }]);
            }
        }

        // 3. Enviar correo
        try {
            await enviarCorreoPedidoExitoso(
                req.usuario.correo,
                req.usuario.nombre,
                nuevoPedido.id_pedido,
                total,
                metodo_pago || 'Normal'
            );
        } catch (mailError) {
            console.error("Error al enviar correo:", mailError);
        }

        return res.status(201).json({
            mensaje: "Pedido creado correctamente",
            pedido: nuevoPedido,
            detalles: detallesValidados
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// MÉTODOS ADICIONALES
// ==========================
export const listarMisPedidos = async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { data, error } = await obtenerPedidosPorUsuario(id_usuario);
        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const listarTodos = async (req, res) => {
    try {
        const { data, error } = await obtenerTodosLosPedidos();
        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerPedidoPorId(id);
        if (error) return res.status(500).json({ error: error.message });
        if (!data) return res.status(404).json({ error: "Pedido no encontrado" });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const cambiarEstado = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body;
        const { data, error } = await actualizarEstadoPedido(id, estado);
        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json({ mensaje: "Estado actualizado", pedido: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const cambiarEstadoYNotificar = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body;
        const { data: pedido, error: errorPedido } = await obtenerPedidoPorId(id);
        if (errorPedido || !pedido) return res.status(404).json({ error: "Pedido no encontrado" });

        const nuevoEstadoPedido = estado === "APROBADO" ? "PREPARANDO" : "CANCELADO";
        await supabase.from("pedidos").update({ estado: nuevoEstadoPedido, updated_at: new Date() }).eq("id_pedido", id);

        const tituloNoti = estado === "APROBADO" ? "¡Pedido Aprobado!" : "Pedido Rechazado";
        const mensajeNoti = estado === "APROBADO"
            ? `Tu pedido #${id} fue aprobado con éxito.`
            : `Lo sentimos, tu pedido #${id} fue rechazado.`;

        // Notificación al usuario con la decisión del administrador
        await supabase.from("notificaciones").insert([{
            id_usuario: pedido.id_usuario,
            titulo: tituloNoti,
            mensaje: mensajeNoti,
            leida: false
        }]);

        return res.status(200).json({ mensaje: `Pedido ${estado.toLowerCase()} correctamente` });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};