import {obtenerCarritoPorUsuario, crearCarrito, agregarDetalleCarrito, obtenerDetallePorProducto, actualizarDetalleCarrito, eliminarDetalleCarrito} from "../models/carrito-model.js";
import { supabase } from "../config/supabase.js";

// ==========================
// OBTENER CARRITO
// ==========================

export const obtener = async (req, res) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;


        let { data: carrito, error } =
            await obtenerCarritoPorUsuario(
                id_usuario
            );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        // Si el usuario todavía no tiene carrito,
        // lo creamos automáticamente.

        if (!carrito) {

            const resultado =
                await crearCarrito({
                    id_usuario
                });


            if (resultado.error) {

                return res.status(500).json({
                    error:
                        resultado.error.message
                });

            }


            carrito = resultado.data;

            carrito.detalle_carrito = [];

        }


        return res.status(200).json(carrito);


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// AGREGAR PRODUCTO
// ==========================

export const agregar = async (req, res) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;


        const {
            id_producto,
            cantidad
        } = req.body;


        // Validar producto

        if (!id_producto) {

            return res.status(400).json({
                error: "El producto es obligatorio"
            });

        }


        // Validar cantidad

        if (
            cantidad === undefined ||
            Number(cantidad) <= 0
        ) {

            return res.status(400).json({
                error:
                    "La cantidad debe ser mayor que 0"
            });

        }


        const cantidadNumerica =
            Number(cantidad);


        // ==========================
        // OBTENER PRODUCTO
        // ==========================

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
                id_producto
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
                    "Producto no encontrado"
            });

        }


        if (!producto.activo) {

            return res.status(400).json({
                error:
                    "El producto no está disponible"
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
                stock_actual
            `)
            .eq(
                "id_producto",
                id_producto
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
                    "El producto no tiene inventario registrado"
            });

        }


        if (
            cantidadNumerica >
            Number(inventario.stock_actual)
        ) {

            return res.status(400).json({

                error:
                    `Stock insuficiente. Stock disponible: ${inventario.stock_actual}`

            });

        }


        // ==========================
        // OBTENER / CREAR CARRITO
        // ==========================

        let {
            data: carrito,
            error: errorCarrito
        } = await obtenerCarritoPorUsuario(
            id_usuario
        );


        if (errorCarrito) {

            return res.status(500).json({
                error:
                    errorCarrito.message
            });

        }


        if (!carrito) {

            const resultado =
                await crearCarrito({
                    id_usuario
                });


            if (resultado.error) {

                return res.status(500).json({
                    error:
                        resultado.error.message
                });

            }


            carrito = resultado.data;

        }


        // ==========================
        // VERIFICAR SI YA ESTÁ
        // ==========================

        const {
            data: detalleExistente,
            error: errorDetalle
        } = await obtenerDetallePorProducto(
            carrito.id_carrito,
            id_producto
        );


        if (errorDetalle) {

            return res.status(500).json({
                error:
                    errorDetalle.message
            });

        }


        // ==========================
        // DETERMINAR PRECIO
        // ==========================

        let precioUnitario =
            Number(producto.precio_detal);


        if (
            producto.precio_mayorista &&
            producto.cantidad_minima_mayorista &&
            cantidadNumerica >=
                Number(
                    producto.cantidad_minima_mayorista
                )
        ) {

            precioUnitario =
                Number(
                    producto.precio_mayorista
                );

        }


        // ==========================
        // SI YA EXISTE
        // ==========================

        if (detalleExistente) {

            const nuevaCantidad =
                Number(
                    detalleExistente.cantidad
                ) + cantidadNumerica;


            if (
                nuevaCantidad >
                Number(inventario.stock_actual)
            ) {

                return res.status(400).json({

                    error:
                        `No hay suficiente stock para agregar esa cantidad. Stock disponible: ${inventario.stock_actual}`

                });

            }


            // Recalcular precio mayorista
            // según la cantidad total.

            if (
                producto.precio_mayorista &&
                producto.cantidad_minima_mayorista &&
                nuevaCantidad >=
                    Number(
                        producto.cantidad_minima_mayorista
                    )
            ) {

                precioUnitario =
                    Number(
                        producto.precio_mayorista
                    );

            } else {

                precioUnitario =
                    Number(
                        producto.precio_detal
                    );

            }


            const subtotal =
                nuevaCantidad *
                precioUnitario;


            const {
                data,
                error
            } = await actualizarDetalleCarrito(

                detalleExistente
                    .id_detalle_carrito,

                {
                    cantidad:
                        nuevaCantidad,

                    precio_unitario:
                        precioUnitario,

                    subtotal,

                    created_at:
                        detalleExistente.created_at
                }
            );


            if (error) {

                return res.status(500).json({
                    error: error.message
                });

            }


            return res.status(200).json({

                mensaje:
                    "Cantidad actualizada en el carrito",

                detalle: data

            });

        }


        // ==========================
        // CREAR DETALLE
        // ==========================

        const subtotal =
            cantidadNumerica *
            precioUnitario;


        const detalle = {

            id_carrito:
                carrito.id_carrito,

            id_producto,

            cantidad:
                cantidadNumerica,

            precio_unitario:
                precioUnitario,

            subtotal

        };


        const {
            data,
            error
        } = await agregarDetalleCarrito(
            detalle
        );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(201).json({

            mensaje:
                "Producto agregado al carrito",

            detalle: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// ACTUALIZAR CANTIDAD
// ==========================

export const actualizar = async (req, res) => {

    try {

        const { idDetalle } =
            req.params;

        const { cantidad } =
            req.body;


        if (
            cantidad === undefined ||
            Number(cantidad) <= 0
        ) {

            return res.status(400).json({
                error:
                    "La cantidad debe ser mayor que 0"
            });

        }


        const cantidadNumerica =
            Number(cantidad);


        // ==========================
        // OBTENER DETALLE
        // ==========================

        const {
            data: detalle,
            error: errorDetalle
        } = await supabase
            .from("detalle_carrito")
            .select(`
                id_detalle_carrito,
                id_carrito,
                id_producto,
                cantidad
            `)
            .eq(
                "id_detalle_carrito",
                idDetalle
            )
            .maybeSingle();


        if (errorDetalle) {

            return res.status(500).json({
                error:
                    errorDetalle.message
            });

        }


        if (!detalle) {

            return res.status(404).json({
                error:
                    "Producto no encontrado en el carrito"
            });

        }


        // ==========================
        // VERIFICAR PROPIETARIO
        // ==========================

        const {
            data: carrito,
            error: errorCarrito
        } = await supabase
            .from("carrito")
            .select("id_carrito, id_usuario")
            .eq(
                "id_carrito",
                detalle.id_carrito
            )
            .maybeSingle();


        if (errorCarrito) {

            return res.status(500).json({
                error:
                    errorCarrito.message
            });

        }


        if (
            !carrito ||
            Number(carrito.id_usuario) !==
                Number(req.usuario.id_usuario)
        ) {

            return res.status(403).json({
                error:
                    "No tiene permiso para modificar este carrito"
            });

        }


        // ==========================
        // VERIFICAR PRODUCTO
        // ==========================

        const {
            data: producto,
            error: errorProducto
        } = await supabase
            .from("productos")
            .select(`
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


        if (!producto || !producto.activo) {

            return res.status(400).json({
                error:
                    "El producto no está disponible"
            });

        }


        // ==========================
        // VERIFICAR STOCK
        // ==========================

        const {
            data: inventario,
            error: errorInventario
        } = await supabase
            .from("inventario")
            .select("stock_actual")
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
                    "No existe inventario para este producto"
            });

        }


        if (
            cantidadNumerica >
            Number(inventario.stock_actual)
        ) {

            return res.status(400).json({

                error:
                    `Stock insuficiente. Stock disponible: ${inventario.stock_actual}`

            });

        }


        // ==========================
        // DETERMINAR PRECIO
        // ==========================

        let precioUnitario =
            Number(producto.precio_detal);


        if (
            producto.precio_mayorista &&
            producto.cantidad_minima_mayorista &&
            cantidadNumerica >=
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
            cantidadNumerica *
            precioUnitario;


        const {
            data,
            error
        } = await actualizarDetalleCarrito(

            idDetalle,

            {
                cantidad:
                    cantidadNumerica,

                precio_unitario:
                    precioUnitario,

                subtotal
            }
        );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(200).json({

            mensaje:
                "Cantidad actualizada correctamente",

            detalle: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// ELIMINAR PRODUCTO
// ==========================

export const eliminar = async (req, res) => {

    try {

        const { idDetalle } =
            req.params;


        const {
            data: detalle,
            error: errorDetalle
        } = await supabase
            .from("detalle_carrito")
            .select(`
                id_detalle_carrito,
                id_carrito
            `)
            .eq(
                "id_detalle_carrito",
                idDetalle
            )
            .maybeSingle();


        if (errorDetalle) {

            return res.status(500).json({
                error:
                    errorDetalle.message
            });

        }


        if (!detalle) {

            return res.status(404).json({
                error:
                    "Producto no encontrado en el carrito"
            });

        }


        const {
            data: carrito,
            error: errorCarrito
        } = await supabase
            .from("carrito")
            .select(`
                id_carrito,
                id_usuario
            `)
            .eq(
                "id_carrito",
                detalle.id_carrito
            )
            .maybeSingle();


        if (errorCarrito) {

            return res.status(500).json({
                error:
                    errorCarrito.message
            });

        }


        if (
            !carrito ||
            Number(carrito.id_usuario) !==
                Number(req.usuario.id_usuario)
        ) {

            return res.status(403).json({
                error:
                    "No tiene permiso para modificar este carrito"
            });

        }


        const {
            data,
            error
        } = await eliminarDetalleCarrito(
            idDetalle
        );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(200).json({

            mensaje:
                "Producto eliminado del carrito",

            detalle: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};