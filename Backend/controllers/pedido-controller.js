import {crearPedido, crearDetallePedido, obtenerPedidosPorUsuario, obtenerTodosLosPedidos, obtenerPedidoPorId, actualizarEstadoPedido} from "../models/pedido-model.js";
import {enviarNotificacion} from "../services/notificacion-service.js";
import { supabase } from "../config/supabase.js";

// ==========================
// CREAR PEDIDO
// ==========================

export const crear = async (req, res) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;

        const {
            direccion_entrega,
            telefono_contacto
        } = req.body;


        // ==========================
        // VALIDAR DATOS
        // ==========================

        if (!direccion_entrega) {

            return res.status(400).json({
                error:
                    "La dirección de entrega es obligatoria"
            });

        }

        if (!telefono_contacto) {

            return res.status(400).json({
                error:
                    "El teléfono de contacto es obligatorio"
            });

        }


        // ==========================
        // OBTENER CARRITO
        // ==========================

        const {
            data: carrito,
            error: errorCarrito
        } = await supabase
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

            return res.status(500).json({
                error:
                    errorCarrito.message
            });

        }


        if (!carrito) {

            return res.status(400).json({
                error:
                    "El usuario no tiene un carrito"
            });

        }


        if (
            !carrito.detalle_carrito ||
            carrito.detalle_carrito.length === 0
        ) {

            return res.status(400).json({
                error:
                    "El carrito está vacío"
            });

        }


        // ==========================
        // VERIFICAR PRODUCTOS
        // Y STOCK
        // ==========================

        let total = 0;

        const detallesValidados = [];


        for (
            const detalle
            of carrito.detalle_carrito
        ) {

            // Obtener producto

            const {
                data: producto,
                error: errorProducto
            } = await supabase
                .from("productos")
                .select(`
                    id_producto,
                    nombre,
                    precio_detal,
                    precio_mayorista,
                    cantidad_minima_mayorista,
                    activo
                `)
                .eq(
                    "id_producto",
                    detalle.id_producto
                )
                .maybeSingle();


            if (errorProducto) {

                return res.status(500).json({
                    error:
                        errorProducto.message
                });

            }


            if (!producto) {

                return res.status(404).json({

                    error:
                        `El producto ${detalle.id_producto} no existe`

                });

            }


            if (!producto.activo) {

                return res.status(400).json({

                    error:
                        `El producto "${producto.nombre}" ya no está disponible`

                });

            }


            // ==========================
            // OBTENER INVENTARIO
            // ==========================

            const {
                data: inventario,
                error: errorInventario
            } = await supabase
                .from("inventario")
                .select(`
                    id_inventario,
                    stock_actual
                `)
                .eq(
                    "id_producto",
                    detalle.id_producto
                )
                .maybeSingle();


            if (errorInventario) {

                return res.status(500).json({
                    error:
                        errorInventario.message
                });

            }


            if (!inventario) {

                return res.status(400).json({

                    error:
                        `El producto "${producto.nombre}" no tiene inventario`

                });

            }


            if (
                Number(detalle.cantidad) >
                Number(inventario.stock_actual)
            ) {

                return res.status(400).json({

                    error:
                        `Stock insuficiente para "${producto.nombre}". Disponible: ${inventario.stock_actual}`

                });

            }


            // ==========================
            // CALCULAR PRECIO
            // ==========================

            let precioUnitario =
                Number(producto.precio_detal);


            if (
                producto.precio_mayorista &&
                producto.cantidad_minima_mayorista &&
                Number(detalle.cantidad) >=
                    Number(
                        producto.cantidad_minima_mayorista
                    )
            ) {

                precioUnitario =
                    Number(
                        producto.precio_mayorista
                    );

            }


            const subtotal =
                Number(detalle.cantidad) *
                precioUnitario;


            total += subtotal;


            detallesValidados.push({

                id_producto:
                    detalle.id_producto,

                cantidad:
                    Number(detalle.cantidad),

                precio_unitario:
                    precioUnitario,

                subtotal

            });

        }


        // ==========================
        // CREAR PEDIDO
        // ==========================

        const pedido = {

            id_usuario,

            direccion_entrega,

            telefono_contacto,

            estado: "PENDIENTE",

            total

        };


        const {
            data: nuevoPedido,
            error: errorPedido
        } = await crearPedido(pedido);


        if (errorPedido) {

            return res.status(500).json({
                error:
                    errorPedido.message
            });

        }


        // ==========================
        // CREAR DETALLES
        // ==========================

        for (
            const detalle
            of detallesValidados
        ) {

            const {
                error
            } = await crearDetallePedido({

                id_pedido:
                    nuevoPedido.id_pedido,

                id_producto:
                    detalle.id_producto,

                cantidad:
                    detalle.cantidad,

                precio_unitario:
                    detalle.precio_unitario,

                subtotal:
                    detalle.subtotal

            });


            if (error) {

                return res.status(500).json({

                    error:
                        `Error creando detalle del pedido: ${error.message}`

                });

            }

        }


        // ==========================
        // DESCONTAR INVENTARIO
        // ==========================

        for (
            const detalle
            of detallesValidados
        ) {

            const {
                data: inventario,
                error: errorInventario
            } = await supabase
                .from("inventario")
                .select(`
                    id_inventario,
                    stock_actual
                `)
                .eq(
                    "id_producto",
                    detalle.id_producto
                )
                .single();


            if (errorInventario) {

                return res.status(500).json({
                    error:
                        errorInventario.message
                });

            }


            const nuevoStock =
                Number(
                    inventario.stock_actual
                ) -
                Number(
                    detalle.cantidad
                );


            if (nuevoStock < 0) {

                return res.status(400).json({

                    error:
                        "El stock no puede quedar negativo"

                });

            }


            const {
                error: errorActualizacion
            } = await supabase
                .from("inventario")
                .update({

                    stock_actual:
                        nuevoStock,

                    updated_at:
                        new Date()

                })
                .eq(
                    "id_inventario",
                    inventario.id_inventario
                );


            if (errorActualizacion) {

                return res.status(500).json({

                    error:
                        errorActualizacion.message

                });

            }


            // ==========================
            // REGISTRAR MOVIMIENTO
            // ==========================

            const {
                error: errorMovimiento
            } = await supabase
                .from("movimientos_inventario")
                .insert({

                    id_producto:
                        detalle.id_producto,

                    tipo_movimiento:
                        "SALIDA",

                    cantidad:
                        detalle.cantidad,

                    observacion:
                        `Salida por pedido #${nuevoPedido.id_pedido}`,

                    id_usuario

                });


            if (errorMovimiento) {

                return res.status(500).json({

                    error:
                        errorMovimiento.message

                });

            }

        }


        // ==========================
        // VACIAR CARRITO
        // ==========================

        const {
            error: errorEliminarCarrito
        } = await supabase
            .from("detalle_carrito")
            .delete()
            .eq(
                "id_carrito",
                carrito.id_carrito
            );


        if (errorEliminarCarrito) {

            return res.status(500).json({

                error:
                    errorEliminarCarrito.message

            });

        }


        // ==========================
        // RESPUESTA
        // ==========================

        await enviarNotificacion(

        id_usuario,

        "Pedido recibido",

        `Tu pedido #${pedido.id_pedido} fue registrado correctamente.`

    );



        return res.status(201).json({

            mensaje:
                "Pedido creado correctamente",

            pedido:
                nuevoPedido,

            detalles:
                detallesValidados

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// LISTAR MIS PEDIDOS
// ==========================

export const listarMisPedidos = async (
    req,
    res
) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;


        const {
            data,
            error
        } = await obtenerPedidosPorUsuario(
            id_usuario
        );


        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }


        return res.status(200).json(data);


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// LISTAR TODOS LOS PEDIDOS
// ==========================

export const listarTodos = async (
    req,
    res
) => {

    try {

        const {
            data,
            error
        } = await obtenerTodosLosPedidos();


        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }


        return res.status(200).json(data);


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// OBTENER PEDIDO POR ID
// ==========================

export const obtenerPedido = async (
    req,
    res
) => {

    try {

        const { id } =
            req.params;


        const {
            data,
            error
        } = await obtenerPedidoPorId(id);


        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }


        if (!data) {

            return res.status(404).json({
                error:
                    "Pedido no encontrado"
            });

        }


        // El cliente solamente puede
        // consultar sus propios pedidos.

        if (
            req.usuario.rol !== "ADMIN" &&
            Number(data.id_usuario) !==
                Number(req.usuario.id_usuario)
        ) {

            return res.status(403).json({

                error:
                    "No tiene permiso para consultar este pedido"

            });

        }


        return res.status(200).json(data);


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// ACTUALIZAR ESTADO
// ==========================

export const cambiarEstado = async (
    req,
    res
) => {

    try {

        const { id } =
            req.params;

        const { estado } =
            req.body;


        const estadosValidos = [

            "PENDIENTE",

            "PAGADO",

            "PREPARANDO",

            "ENVIADO",

            "ENTREGADO",

            "CANCELADO"

        ];


        if (
            !estadosValidos.includes(
                estado
            )
        ) {

            return res.status(400).json({

                error:
                    "Estado de pedido inválido"

            });

        }


        // ==========================
        // VERIFICAR PEDIDO
        // ==========================

        const {
            data: pedido,
            error: errorPedido
        } = await obtenerPedidoPorId(id);


        if (errorPedido) {

            return res.status(500).json({
                error:
                    errorPedido.message
            });

        }


        if (!pedido) {

            return res.status(404).json({
                error:
                    "Pedido no encontrado"
            });

        }


        const {
            data,
            error
        } = await actualizarEstadoPedido(
            id,
            estado
        );


        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }


        return res.status(200).json({

            mensaje:
                "Estado del pedido actualizado correctamente",

            pedido:
                data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};