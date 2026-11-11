import { supabase } from "../config/supabase.js";
import { enviarCorreoPedidoExitoso } from "../services/notificacion-service.js";

// Función auxiliar con depuración extrema para Supabase Storage
const subirComprobanteAStorage = async (base64Data) => {
    if (!base64Data) {
        console.log("⚠️ [Storage] No se proporcionó ninguna cadena de comprobante.");
        return null;
    }

    if (base64Data.startsWith('http://') || base64Data.startsWith('https://')) {
        console.log("ℹ️ [Storage] El comprobante ya es una URL web:", base64Data);
        return base64Data;
    }

    try {
        let buffer;
        let contentType = 'image/jpeg';

        if (base64Data.includes(';base64,')) {
            const arr = base64Data.split(';base64,');
            const mimeMatch = arr[0].match(/:(.*?);/);
            if (mimeMatch) contentType = mimeMatch[1];
            buffer = Buffer.from(arr[1], 'base64');
        } else {
            buffer = Buffer.from(base64Data, 'base64');
        }

        const fileUint8Array = new Uint8Array(buffer);
        const fileName = `comprobante_${Date.now()}.jpg`;

        console.log(`📤 [Storage] Subiendo imagen al bucket 'comprobantes' (${fileName}), tamaño: ${fileUint8Array.length} bytes...`);

        const { data: uploadData, error: errorStorage } = await supabase.storage
            .from('comprobantes')
            .upload(fileName, fileUint8Array, {
                contentType,
                upsert: true
            });

        if (errorStorage) {
            console.error("❌ [Storage] ERROR DE SUPABASE STORAGE:", errorStorage.message);
            return null;
        }

        console.log("✅ [Storage] Imagen subida exitosamente a Supabase:", uploadData);

        const { data: publicUrlData } = supabase.storage
            .from('comprobantes')
            .getPublicUrl(fileName);

        console.log("🔗 [Storage] URL pública generada:", publicUrlData.publicUrl);
        return publicUrlData.publicUrl;
    } catch (err) {
        console.error("❌ [Storage] EXCEPCIÓN CRÍTICA procesando la imagen:", err.message);
        return null;
    }
};

export const crear = async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { direccion_entrega, telefono_contacto, metodo_pago, comprobante_url } = req.body;

        console.log("📥 [Pedido] Solicitud recibida en el backend:", {
            id_usuario,
            metodo_pago,
            direccion_entrega,
            telefono_contacto,
            tieneComprobanteUrl: !!comprobante_url,
            largoComprobanteUrl: comprobante_url ? comprobante_url.length : 0
        });

        if (!direccion_entrega || !telefono_contacto) {
            return res.status(400).json({ error: "Faltan datos obligatorios de entrega o contacto" });
        }

        // 1. Procesar comprobante
        let urlComprobanteFinal = null;
        if (comprobante_url) {
            urlComprobanteFinal = await subirComprobanteAStorage(comprobante_url);
        } else {
            console.log("⚠️ [Pedido] Atencion: 'comprobante_url' llegó vacío o nulo desde el cliente.");
        }

        // 2. Obtener y validar el carrito del usuario
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

        if (errorCarrito || !carrito || !carrito.detalle_carrito || carrito.detalle_carrito.length === 0) {
            return res.status(400).json({ error: "El carrito está vacío o no se pudo cargar" });
        }

        let total = 0;
        const detallesValidados = [];
        const resumenProductos = [];

        for (const detalle of carrito.detalle_carrito) {
            const { data: producto, error: errorProducto } = await supabase
                .from("productos")
                .select(`id_producto, nombre, presentacion, tapa, precio_detal, precio_mayorista, cantidad_minima_mayorista, activo`)
                .eq("id_producto", detalle.id_producto)
                .maybeSingle();

            if (errorProducto || !producto || !producto.activo) {
                return res.status(404).json({ error: `Producto no disponible` });
            }

            const { data: inventario } = await supabase
                .from("inventario")
                .select(`id_inventario, stock_actual`)
                .eq("id_producto", detalle.id_producto)
                .maybeSingle();

            if (!inventario || Number(detalle.cantidad) > Number(inventario.stock_actual)) {
                return res.status(400).json({ error: `Stock insuficiente para ${producto.nombre}` });
            }

            let precioUnitario = Number(producto.precio_detal);
            if (producto.precio_mayorista && producto.cantidad_minima_mayorista && Number(detalle.cantidad) >= Number(producto.cantidad_minima_mayorista)) {
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

            const detalleExtra = producto.tapa ? ` (Tapa: ${producto.tapa})` : (producto.presentacion ? ` (${producto.presentacion})` : '');
            resumenProductos.push(`${producto.nombre}${detalleExtra} x${detalle.cantidad}`);
        }

        // 3. Crear el pedido principal
        const { data: nuevoPedido, error: errorPedido } = await supabase
            .from("pedidos")
            .insert([{
                id_usuario,
                direccion_entrega,
                telefono_contacto,
                estado: "PENDIENTE",
                total
            }])
            .select()
            .single();

        if (errorPedido) {
            return res.status(500).json({ error: errorPedido.message });
        }

        // 4. Registrar pago guardando la URL del comprobante en la columna 'comprobantes'
        const metodoPagoLimpio = (metodo_pago || "nequi").toLowerCase();

        console.log(`💾 [Base de Datos] Insertando en pagos -> ID Pedido: ${nuevoPedido.id_pedido}, Comprobante a guardar:`, urlComprobanteFinal);

        const { error: errorPago } = await supabase
            .from("pagos")
            .insert([{
                id_pedido: nuevoPedido.id_pedido,
                metodo_pago: metodoPagoLimpio,
                valor: total,
                estado: "PENDIENTE",
                comprobantes: urlComprobanteFinal,
                fecha_pago: new Date().toISOString()
            }]);

        if (errorPago) {
            console.error("❌ [Base de Datos] ERROR AL INSERTAR EN PAGOS:", errorPago.message);
            return res.status(500).json({ error: `Error en pagos: ${errorPago.message}` });
        }

        // 5. Insertar detalles del pedido
        for (const detalle of detallesValidados) {
            await supabase.from("detalle_pedido").insert([{
                id_pedido: nuevoPedido.id_pedido,
                id_producto: detalle.id_producto,
                cantidad: detalle.cantidad,
                precio_unitario: detalle.precio_unitario,
                subtotal: detalle.subtotal
            }]);
        }

        // 6. Descontar inventario
        for (const detalle of detallesValidados) {
            const { data: inventario } = await supabase
                .from("inventario")
                .select(`id_inventario, stock_actual`)
                .eq("id_producto", detalle.id_producto)
                .single();

            if (inventario) {
                const nuevoStock = Number(inventario.stock_actual) - Number(detalle.cantidad);
                await supabase
                    .from("inventario")
                    .update({ stock_actual: nuevoStock, updated_at: new Date() })
                    .eq("id_inventario", inventario.id_inventario);
            }
        }

        // 7. Vaciar carrito
        await supabase
            .from("detalle_carrito")
            .delete()
            .eq("id_carrito", carrito.id_carrito);

        // 8. Notificaciones para administradores
        const { data: adminUsers } = await supabase
            .from("usuarios")
            .select("id_usuario")
            .or("rol.eq.ADMIN,rol.eq.admin");

        const mensajeAdmin = `Nuevo Pedido #${nuevoPedido.id_pedido}\nCliente: ${req.usuario.nombre}\nMétodo: ${metodo_pago || 'Nequi'}\nCompra: ${resumenProductos.join(', ')}\nTotal: $${total}`;

        if (adminUsers && adminUsers.length > 0) {
            for (const admin of adminUsers) {
                await supabase.from("notificaciones").insert([{
                    id_usuario: admin.id_usuario,
                    titulo: "Nuevo Pedido Recibido",
                    mensaje: mensajeAdmin,
                    comprobante: urlComprobanteFinal,
                    leida: false
                }]);
            }
        }

        // 9. Notificación automática para el cliente
        const mensajeCliente = `Tu pedido #${nuevoPedido.id_pedido} (${resumenProductos.join(', ')}) fue realizado con éxito y está en revisión.`;
        await supabase.from("notificaciones").insert([{
            id_usuario: id_usuario,
            titulo: "¡Pedido Realizado con Éxito!",
            mensaje: mensajeCliente,
            leida: false
        }]);

        try {
            await enviarCorreoPedidoExitoso(
                req.usuario.correo,
                req.usuario.nombre,
                nuevoPedido.id_pedido,
                total,
                metodo_pago || 'Nequi'
            );
        } catch (_) {}

        return res.status(201).json({
            mensaje: "Pedido y pago procesados con éxito",
            pedido: nuevoPedido
        });

    } catch (error) {
        console.error("❌ [Servidor] Excepción general en crear pedido:", error);
        return res.status(500).json({ error: error.message });
    }
};

export const listarMisPedidos = async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { data, error } = await supabase
            .from("pedidos")
            .select("*, detalle_pedido(*, productos(*))")
            .eq("id_usuario", id_usuario)
            .order("created_at", { ascending: false });

        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const listarTodos = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("pedidos")
            .select("*, usuarios(nombre, correo), detalle_pedido(*, productos(*))")
            .order("created_at", { ascending: false });

        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("pedidos")
            .select("*, usuarios(nombre, correo), detalle_pedido(*, productos(*))")
            .eq("id_pedido", id)
            .maybeSingle();

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
        const { data, error } = await supabase
            .from("pedidos")
            .update({ estado })
            .eq("id_pedido", id)
            .select()
            .single();

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
        
        const { data: pedido, error: errorPedido } = await supabase
            .from("pedidos")
            .select("*, usuarios(nombre, correo)")
            .eq("id_pedido", id)
            .maybeSingle();

        if (errorPedido || !pedido) return res.status(404).json({ error: "Pedido no encontrado" });

        const nuevoEstadoPedido = estado === "APROBADO" ? "PREPARANDO" : "CANCELADO";
        await supabase.from("pedidos").update({ estado: nuevoEstadoPedido, updated_at: new Date() }).eq("id_pedido", id);

        const tituloNoti = estado === "APROBADO" ? "¡Pedido Aprobado!" : "Pedido Rechazado";
        const mensajeNoti = estado === "APROBADO"
            ? `Tu pedido #${id} fue aprobado con éxito.`
            : `Lo sentimos, tu pedido #${id} fue rechazado.`;

        // Se inserta correctamente sin enviar columnas ajenas a la tabla 'notificaciones'
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