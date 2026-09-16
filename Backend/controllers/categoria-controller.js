import {crearCategoria, obtenerCategorias,
    obtenerCategoriaPorId, obtenerCategoriaPorNombre,
    actualizarCategoria, desactivarCategoria, activarCategoria} from "../models/categoria-model.js";

// ==========================
// CREAR CATEGORÍA
// ==========================

export const crear = async (req, res) => {

    try {

        const {
            nombre,
            descripcion
        } = req.body;

        // Validar nombre

        if (!nombre) {
            return res.status(400).json({
                error: "El nombre de la categoría es obligatorio"
            });
        }

        // Verificar si ya existe

        const { data: categoriaExiste } =
            await obtenerCategoriaPorNombre(nombre);

        if (categoriaExiste) {
            return res.status(400).json({
                error: "La categoría ya existe"
            });
        }

        const nuevaCategoria = {
            nombre,
            descripcion: descripcion || null,
            activo: true
        };

        const { data, error } =
            await crearCategoria(nuevaCategoria);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(201).json({
            mensaje: "Categoría creada correctamente",
            categoria: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};

// ==========================
// ACTIVAR CATEGORÍA
// ==========================

export const activar = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await activarCategoria(id);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Categoría activada correctamente",
            categoria: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// OBTENER TODAS LAS CATEGORÍAS
// ==========================

export const listarCategorias = async (req, res) => {

    try {

        const { data, error } =
            await obtenerCategorias();

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
// OBTENER CATEGORÍA POR ID
// ==========================

export const obtener = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await obtenerCategoriaPorId(id);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        if (!data) {
            return res.status(404).json({
                error: "Categoría no encontrada"
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
// ACTUALIZAR CATEGORÍA
// ==========================

export const actualizar = async (req, res) => {

    try {

        const { id } = req.params;

        const {
            nombre,
            descripcion
        } = req.body;

        if (!nombre) {
            return res.status(400).json({
                error: "El nombre de la categoría es obligatorio"
            });
        }

        const datosActualizados = {
            nombre,
            descripcion: descripcion || null,
            updated_at: new Date()
        };

        const { data, error } =
            await actualizarCategoria(
                id,
                datosActualizados
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Categoría actualizada correctamente",
            categoria: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// DESACTIVAR CATEGORÍA
// ==========================

export const desactivar = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await desactivarCategoria(id);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Categoría desactivada correctamente",
            categoria: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};