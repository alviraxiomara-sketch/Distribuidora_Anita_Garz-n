import {crearProducto, obtenerProductos, obtenerProductoPorId, obtenerProductosPorCategoria, buscarProductosPorNombre, actualizarProducto, desactivarProducto, activarProducto} from "../models/producto-model.js";
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
// LISTAR PRODUCTOS
// ==========================

export const listarProductos = async (req, res) => {
    try {
        const { tipo } = req.query;
        const { data, error } = await obtenerProductos();
        
        if (error) {
            return res.status(500).json({ error: error.message });
        }

        if (tipo) {
            const productosFiltrados = data.filter(p => p.tipo && p.tipo.toLowerCase() === tipo.toLowerCase());
            return res.status(200).json(productosFiltrados);
        }

        return res.status(200).json(data);
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

        if (!id_categoria || !nombre || precio_detal === undefined || precio_detal === null || !tipo) {
            return res.status(400).json({
                error: "Categoría, nombre, precio al detal y tipo son obligatorios"
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

        const datosActualizados = {
            id_categoria,
            nombre,
            presentacion: presentacion || null,
            tapa: tapa || null,
            precio_detal,
            precio_mayorista: precio_mayorista || null,
            cantidad_minima_mayorista: cantidad_minima_mayorista || null,
            tipo,
            updated_at: new Date()
        };

        if (imagen_url) {
            datosActualizados.imagen_url = imagen_url;
        }

        const { data, error } = await actualizarProducto(id, datosActualizados);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        if (stock_actual !== undefined && stock_actual !== '') {
            await actualizarInventarioPorProducto(id, { stock_actual: Number(stock_actual) });
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