import {crearProducto, obtenerProductos, obtenerProductoPorId, obtenerProductosPorCategoria, buscarProductosPorNombre, actualizarProducto, desactivarProducto} from "../models/producto-model.js";

// ==========================
// CREAR PRODUCTO
// ==========================

export const crear = async (req, res) => {

    try {

        const {
            id_categoria,
            nombre,
            descripcion,
            presentacion,
            precio_detal,
            precio_mayorista,
            cantidad_minima_mayorista
        } = req.body;

        const imagen_url =
    req.file
        ? req.file.path
        : null;


        // Validar campos obligatorios

        if (
            !id_categoria ||
            !nombre ||
            precio_detal === undefined ||
            precio_detal === null
        ) {

            return res.status(400).json({
                error: "Categoría, nombre y precio de venta al detal son obligatorios"
            });

        }


        // Validar precio detal

        if (Number(precio_detal) <= 0) {

            return res.status(400).json({
                error: "El precio al detal debe ser mayor que 0"
            });

        }


        // Validar precio mayorista

        if (
            precio_mayorista !== undefined &&
            precio_mayorista !== null &&
            Number(precio_mayorista) <= 0
        ) {

            return res.status(400).json({
                error: "El precio mayorista debe ser mayor que 0"
            });

        }


        const nuevoProducto = {

            id_categoria,
            nombre,
            descripcion: descripcion || null,
            presentacion: presentacion || null,
            precio_detal,
            precio_mayorista:
                precio_mayorista ?? null,
            imagen_url:
                imagen_url || null,
            activo: true,
            cantidad_minima_mayorista:
            cantidad_minima_mayorista ?? null

        };


        const { data, error } =
            await crearProducto(nuevoProducto);


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(201).json({

            mensaje: "Producto creado correctamente",

            producto: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// LISTAR PRODUCTOS
// ==========================

export const listarProductos = async (req, res) => {

    try {

        const { data, error } =
            await obtenerProductos();


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
// OBTENER PRODUCTO POR ID
// ==========================

export const obtener = async (req, res) => {

    try {

        const { id } = req.params;


        const { data, error } =
            await obtenerProductoPorId(id);


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        if (!data) {

            return res.status(404).json({
                error: "Producto no encontrado"
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
// PRODUCTOS POR CATEGORÍA
// ==========================

export const listarPorCategoria = async (req, res) => {

    try {

        const { idCategoria } = req.params;


        const { data, error } =
            await obtenerProductosPorCategoria(
                idCategoria
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


// ==========================
// BUSCAR PRODUCTOS
// ==========================

export const buscar = async (req, res) => {

    try {

        const { nombre } = req.query;


        if (!nombre) {

            return res.status(400).json({
                error: "Debe enviar un nombre para realizar la búsqueda"
            });

        }


        const { data, error } =
            await buscarProductosPorNombre(nombre);


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
// ACTUALIZAR PRODUCTO
// ==========================

export const actualizar = async (req, res) => {

    try {

        const { id } = req.params;

        const {
            id_categoria,
            nombre,
            descripcion,
            presentacion,
            precio_detal,
            precio_mayorista,
            cantidad_minima_mayorista
        } = req.body;
        
        const imagen_url =
    req.file
        ? req.file.path
        : null;


        if (
            !id_categoria ||
            !nombre ||
            precio_detal === undefined ||
            precio_detal === null
        ) {

            return res.status(400).json({
                error: "Categoría, nombre y precio al detal son obligatorios"
            });

        }


        if (Number(precio_detal) <= 0) {

            return res.status(400).json({
                error: "El precio al detal debe ser mayor que 0"
            });

        }


        if (
            precio_mayorista !== undefined &&
            precio_mayorista !== null &&
            Number(precio_mayorista) <= 0
        ) {

            return res.status(400).json({
                error: "El precio mayorista debe ser mayor que 0"
            });

        }


        const datosActualizados = {

            id_categoria,
            nombre,
            descripcion: descripcion || null,
            presentacion: presentacion || null,
            precio_detal,
            precio_mayorista:
                precio_mayorista || null,
            imagen_url:
                imagen_url || null,
            cantidad_minima_mayorista:
                cantidad_minima_mayorista || null,
            updated_at: new Date()

        };


        const { data, error } =
            await actualizarProducto(
                id,
                datosActualizados
            );


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(200).json({

            mensaje: "Producto actualizado correctamente",

            producto: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// DESACTIVAR PRODUCTO
// ==========================

export const desactivar = async (req, res) => {

    try {

        const { id } = req.params;


        const { data, error } =
            await desactivarProducto(id);


        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }


        return res.status(200).json({

            mensaje: "Producto desactivado correctamente",

            producto: data

        });


    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};