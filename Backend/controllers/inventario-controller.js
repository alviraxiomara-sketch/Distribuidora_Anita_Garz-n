import {obtenerInventario, obtenerInventarioPorProducto, crearInventario, actualizarStock, actualizarStockMinimo, registrarMovimiento, obtenerMovimientos, obtenerMovimientosPorProducto} from "../models/inventario-model.js";

// ==========================
// OBTENER TODO EL INVENTARIO
// ==========================

export const listarInventario = async (req, res) => {

    try {

        const { data, error } =
            await obtenerInventario();

        if (error) {

            return res.status(500).json({
                error: error.message
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
// OBTENER INVENTARIO POR PRODUCTO
// ==========================

export const obtenerInventarioProducto = async (
    req,
    res
) => {

    try {

        const { idProducto } = req.params;

        const { data, error } =
            await obtenerInventarioPorProducto(
                idProducto
            );

        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }

        if (!data) {

            return res.status(404).json({
                error: "No existe inventario para este producto"
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
// CREAR INVENTARIO
// ==========================

export const crear = async (req, res) => {

    try {

        const {
            id_producto,
            stock_actual,
            stock_minimo
        } = req.body;


        if (!id_producto) {

            return res.status(400).json({
                error: "El producto es obligatorio"
            });

        }


        if (
            stock_actual !== undefined &&
            Number(stock_actual) < 0
        ) {

            return res.status(400).json({
                error: "El stock actual no puede ser negativo"
            });

        }


        if (
            stock_minimo !== undefined &&
            Number(stock_minimo) < 0
        ) {

            return res.status(400).json({
                error: "El stock mínimo no puede ser negativo"
            });

        }


        const nuevoInventario = {

            id_producto,

            stock_actual:
                stock_actual ?? 0,

            stock_minimo:
                stock_minimo ?? 5

        };


        const { data, error } =
            await crearInventario(
                nuevoInventario
            );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(201).json({

            mensaje: "Inventario creado correctamente",

            inventario: data

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// REGISTRAR ENTRADA
// ==========================

export const entrada = async (req, res) => {

    try {

        const { idProducto } = req.params;

        const {
            cantidad,
            observacion
        } = req.body;


        if (
            cantidad === undefined ||
            Number(cantidad) <= 0
        ) {

            return res.status(400).json({
                error: "La cantidad debe ser mayor que 0"
            });

        }


        const { data: inventario, error: errorInventario } =
            await obtenerInventarioPorProducto(
                idProducto
            );


        if (errorInventario) {

            return res.status(500).json({
                error: errorInventario.message
            });

        }


        if (!inventario) {

            return res.status(404).json({
                error: "No existe inventario para este producto"
            });

        }


        const nuevoStock =
            Number(inventario.stock_actual) +
            Number(cantidad);


        const {
            data: stockActualizado,
            error: errorStock
        } = await actualizarStock(
            idProducto,
            nuevoStock
        );


        if (errorStock) {

            return res.status(500).json({
                error: errorStock.message
            });

        }


        const movimiento = {

            id_producto: idProducto,

            tipo_movimiento: "ENTRADA",

            cantidad: Number(cantidad),

            observacion:
                observacion || null,

            id_usuario:
                req.usuario.id_usuario

        };


        const {
            data: movimientoRegistrado,
            error: errorMovimiento
        } = await registrarMovimiento(
            movimiento
        );


        if (errorMovimiento) {

            return res.status(500).json({
                error: errorMovimiento.message
            });

        }


        return res.status(200).json({

            mensaje: "Entrada de inventario registrada correctamente",

            inventario: stockActualizado,

            movimiento: movimientoRegistrado

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// REGISTRAR SALIDA
// ==========================

export const salida = async (req, res) => {

    try {

        const { idProducto } = req.params;

        const {
            cantidad,
            observacion
        } = req.body;


        if (
            cantidad === undefined ||
            Number(cantidad) <= 0
        ) {

            return res.status(400).json({
                error: "La cantidad debe ser mayor que 0"
            });

        }


        const { data: inventario, error: errorInventario } =
            await obtenerInventarioPorProducto(
                idProducto
            );


        if (errorInventario) {

            return res.status(500).json({
                error: errorInventario.message
            });

        }


        if (!inventario) {

            return res.status(404).json({
                error: "No existe inventario para este producto"
            });

        }


        const stockActual =
            Number(inventario.stock_actual);

        const cantidadSalida =
            Number(cantidad);


        if (cantidadSalida > stockActual) {

            return res.status(400).json({

                error:
                    `Stock insuficiente. Stock actual: ${stockActual}`

            });

        }


        const nuevoStock =
            stockActual -
            cantidadSalida;


        const {
            data: stockActualizado,
            error: errorStock
        } = await actualizarStock(
            idProducto,
            nuevoStock
        );


        if (errorStock) {

            return res.status(500).json({
                error: errorStock.message
            });

        }


        const movimiento = {

            id_producto: idProducto,

            tipo_movimiento: "SALIDA",

            cantidad: cantidadSalida,

            observacion:
                observacion || null,

            id_usuario:
                req.usuario.id_usuario

        };


        const {
            data: movimientoRegistrado,
            error: errorMovimiento
        } = await registrarMovimiento(
            movimiento
        );


        if (errorMovimiento) {

            return res.status(500).json({
                error: errorMovimiento.message
            });

        }


        return res.status(200).json({

            mensaje: "Salida de inventario registrada correctamente",

            inventario: stockActualizado,

            movimiento: movimientoRegistrado

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// REGISTRAR AJUSTE
// ==========================

export const ajuste = async (req, res) => {

    try {

        const { idProducto } = req.params;

        const {
            cantidad,
            observacion
        } = req.body;


        if (
            cantidad === undefined ||
            Number(cantidad) < 0
        ) {

            return res.status(400).json({
                error: "La cantidad de ajuste no puede ser negativa"
            });

        }


        if (!observacion) {

            return res.status(400).json({
                error: "La observación es obligatoria para un ajuste"
            });

        }


        const { data: inventario, error: errorInventario } =
            await obtenerInventarioPorProducto(
                idProducto
            );


        if (errorInventario) {

            return res.status(500).json({
                error: errorInventario.message
            });

        }


        if (!inventario) {

            return res.status(404).json({
                error: "No existe inventario para este producto"
            });

        }


        const {
            data: stockActualizado,
            error: errorStock
        } = await actualizarStock(
            idProducto,
            Number(cantidad)
        );


        if (errorStock) {

            return res.status(500).json({
                error: errorStock.message
            });

        }


        const movimiento = {

            id_producto: idProducto,

            tipo_movimiento: "AJUSTE",

            cantidad: Number(cantidad),

            observacion,

            id_usuario:
                req.usuario.id_usuario

        };


        const {
            data: movimientoRegistrado,
            error: errorMovimiento
        } = await registrarMovimiento(
            movimiento
        );


        if (errorMovimiento) {

            return res.status(500).json({
                error: errorMovimiento.message
            });

        }


        return res.status(200).json({

            mensaje: "Ajuste de inventario realizado correctamente",

            inventario: stockActualizado,

            movimiento: movimientoRegistrado

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// ACTUALIZAR STOCK MÍNIMO
// ==========================

export const actualizarMinimo = async (
    req,
    res
) => {

    try {

        const { idProducto } = req.params;

        const { stock_minimo } =
            req.body;


        if (
            stock_minimo === undefined ||
            Number(stock_minimo) < 0
        ) {

            return res.status(400).json({
                error: "El stock mínimo no puede ser negativo"
            });

        }


        const {
            data,
            error
        } = await actualizarStockMinimo(
            idProducto,
            Number(stock_minimo)
        );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        if (!data) {

            return res.status(404).json({
                error: "No existe inventario para este producto"
            });

        }


        return res.status(200).json({

            mensaje: "Stock mínimo actualizado correctamente",

            inventario: data

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// OBTENER MOVIMIENTOS
// ==========================

export const listarMovimientos = async (
    req,
    res
) => {

    try {

        const { data, error } =
            await obtenerMovimientos();


        if (error) {

            return res.status(500).json({
                error: error.message
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
// MOVIMIENTOS POR PRODUCTO
// ==========================

export const listarMovimientosProducto = async (
    req,
    res
) => {

    try {

        const { idProducto } =
            req.params;


        const {
            data,
            error
        } = await obtenerMovimientosPorProducto(
            idProducto
        );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(200).json(data);

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};