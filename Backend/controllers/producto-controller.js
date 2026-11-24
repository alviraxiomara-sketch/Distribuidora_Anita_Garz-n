import {crearProducto, obtenerProductos, obtenerProductoPorId, obtenerProductosPorCategoria, buscarProductosPorNombre, actualizarProducto, desactivarProducto, activarProducto, eliminarProducto} from "../models/producto-model.js";
import {crearInventario, actualizarInventarioPorProducto} from "../models/inventario-model.js";

// ==========================
// CREAR PRODUCTO
// ==========================

export const crear = async (req, res) => {
    try {
        const {
            id_categoria,
            nombre,
            presentacion,
            tapa,
            precio_detal,
            precio_mayorista,
            cantidad_minima_mayorista,
            cantidad,
            tipo
        } = req.body;

        const imagen_url = req.file ? req.file.path : null;

        if (!id_categoria || !nombre || precio_detal === undefined || precio_detal === null || !tipo) {
            return res.status(400).json({
                error: "Categoría, nombre, precio de venta al detal y tipo son obligatorios"
            });
        }

        if (Number(precio_detal) <= 0) {
            return res.status(400).json({
                error: "El precio al detal debe ser mayor que 0"
            });
        }

        if (precio_mayorista !== undefined && precio_mayorista !== null && Number(precio_mayorista) <= 0) {
            return res.status(400).json({
                error: "El precio mayorista debe ser mayor que 0"
            });
        }

        const nuevoProducto = {
            id_categoria,
            nombre,
            presentacion: presentacion || null,
            tapa: tapa || null,
            precio_detal,
            precio_mayorista: precio_mayorista ?? null,
            imagen_url: imagen_url || null,
            activo: true,
            cantidad_minima_mayorista: cantidad_minima_mayorista ?? null,
            tipo
        };

        const { data: productoCreado, error: errorProducto } = await crearProducto(nuevoProducto);

        if (errorProducto) {
            return res.status(500).json({ error: errorProducto.message });
        }

        const stockInicial = cantidad !== undefined && cantidad !== '' ? Number(cantidad) : 0;
        
        const nuevoInventario = {
            id_producto: productoCreado.id_producto,
            stock_actual: stockInicial,
            stock_minimo: 20
        };

        const { error: errorInventario } = await crearInventario(nuevoInventario);

        if (errorInventario) {
            console.error("Error al crear el inventario inicial:", errorInventario.message);
        }

        return res.status(201).json({
            mensaje: "Producto e inventario creados correctamente",
            producto: productoCreado
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// LISTAR PRODUCTOS (FILTRANDO POR TIPO)
// ==========================

export const listarProductos = async (req, res) => {
    try {
        const { tipo } = req.query; // Capturamos el tipo (Nacionales / Importadas)
        const { data, error } = await obtenerProductos();
        
        if (error) {
            return res.status(500).json({ error: error.message });
        }

        let productosFiltrados = data;

        console.log("Total productos en BD:", data.length);
        console.log("Tipo recibido:", tipo);

        // Filtrar por tipo si viene en la query (ignorando mayúsculas/minúsculas y espacios)
        if (tipo) {
            productosFiltrados = productosFiltrados.filter(
                p => p.tipo && p.tipo.trim().toLowerCase() === tipo.trim().toLowerCase()
            );
        }

        return res.status(200).json(productosFiltrados);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// OBTENER PRODUCTO POR ID
// ==========================

export const obtener = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerProductoPorId(id);

        if (error) {
            return res.status(500).json({ error: error.message });
        }
        if (!data) {
            return res.status(404).json({ error: "Producto no encontrado" });
        }

        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// PRODUCTOS POR CATEGORÍA
// ==========================

export const listarPorCategoria = async (req, res) => {
    try {
        const { idCategoria } = req.params;
        const { data, error } = await obtenerProductosPorCategoria(idCategoria);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// BUSCAR PRODUCTOS
// ==========================

export const buscar = async (req, res) => {
    try {
        const { nombre } = req.query;

        if (!nombre) {
            return res.status(400).json({ error: "Debe enviar un nombre para realizar la búsqueda" });
        }

        const { data, error } = await buscarProductosPorNombre(nombre);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// ACTUALIZAR PRODUCTO
// ==========================

export const actualizar = async (req, res) => {
    try {
        const { id } = req.params;

        const {
            id_categoria,
            nombre,
            presentacion,
            tapa,
            precio_detal,
            precio_mayorista,
            cantidad_minima_mayorista,
            stock_actual,
            tipo
        } = req.body;

        const imagen_url = req.file ? req.file.path : null;

        // En la edición solo son obligatorios nombre y precio al detal.
        // "tipo", categoría, etc. son opcionales: si no vienen, se conserva lo que ya hay en la BD.
        if (!nombre || precio_detal === undefined || precio_detal === null || precio_detal === '') {
            return res.status(400).json({
                error: "Nombre y precio al detal son obligatorios"
            });
        }

        if (Number(precio_detal) <= 0) {
            return res.status(400).json({
                error: "El precio al detal debe ser mayor que 0"
            });
        }

        if (precio_mayorista !== undefined && precio_mayorista !== null && precio_mayorista !== '' && Number(precio_mayorista) <= 0) {
            return res.status(400).json({
                error: "El precio mayorista debe ser mayor que 0"
            });
        }

        // Solo se actualizan los campos que realmente llegaron
        const datosActualizados = {
            nombre,
            precio_detal,
            updated_at: new Date()
        };

        if (id_categoria) datosActualizados.id_categoria = id_categoria;
        if (tipo) datosActualizados.tipo = tipo;
        if (presentacion !== undefined) datosActualizados.presentacion = presentacion || null;
        if (tapa !== undefined) datosActualizados.tapa = tapa || null;
        if (precio_mayorista !== undefined) datosActualizados.precio_mayorista = precio_mayorista || null;
        if (cantidad_minima_mayorista !== undefined) datosActualizados.cantidad_minima_mayorista = cantidad_minima_mayorista || null;
        if (imagen_url) datosActualizados.imagen_url = imagen_url;

        const { data, error } = await actualizarProducto(id, datosActualizados);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        if (stock_actual !== undefined && stock_actual !== '') {
            const { error: errorStock } = await actualizarInventarioPorProducto(id, { stock_actual: Number(stock_actual) });

            if (errorStock) {
                return res.status(500).json({ error: "Se guardó el producto pero falló el stock: " + errorStock.message });
            }
        }

        return res.status(200).json({
            mensaje: "Producto actualizado correctamente",
            producto: data
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// DESACTIVAR PRODUCTO
// ==========================

export const desactivar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await desactivarProducto(id);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json({
            mensaje: "Producto desactivado correctamente",
            producto: data
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// ACTIVAR PRODUCTO
// ==========================

export const activar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await activarProducto(id);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json({
            mensaje: "Producto activado correctamente",
            producto: data
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// ==========================
// ELIMINAR PRODUCTO
// ==========================

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;

        const { data: existente, error: errorBuscar } = await obtenerProductoPorId(id);

        if (errorBuscar) {
            return res.status(500).json({ error: errorBuscar.message });
        }
        if (!existente) {
            return res.status(404).json({ error: "Producto no encontrado" });
        }

        const { error } = await eliminarProducto(id);

        if (error) {
            // 23503 = el producto tiene pedidos, movimientos o carritos asociados
            if (error.code === "23503") {
                return res.status(409).json({
                    error: "El producto tiene pedidos o movimientos asociados y no se puede eliminar. Puedes desactivarlo."
                });
            }
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json({ mensaje: "Producto eliminado correctamente" });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};