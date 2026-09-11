import {obtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario} from "../models/user-model.js";


// ==========================
// OBTENER TODOS LOS USUARIOS
// ==========================

export const listarUsuarios = async (req, res) => {

    try {

        const { data, error } =
            await obtenerUsuarios();

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
// OBTENER USUARIO POR ID
// ==========================

export const obtenerUsuario = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await obtenerUsuarioPorId(id);

        if (error || !data) {
            return res.status(404).json({
                error: "Usuario no encontrado"
            });
        }

        console.log ("DATA:", data);
        const token =jwt.sign({
            id_usuario: data.id_usuario,
            
        },SECRET);

        return res.status(200).json(data);

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// CAMBIAR ROL
// ==========================

export const cambiarRol = async (req, res) => {

    try {

        const { id } = req.params;
        const { rol } = req.body;

        const rolesValidos = [
            "ADMIN",
            "CLIENTE",
            "MAYORISTA"
        ];

        if (!rolesValidos.includes(rol)) {
            return res.status(400).json({
                error: "Rol inválido"
            });
        }

        const { data, error } =
            await actualizarUsuario(
                id,
                {
                    rol,
                    updated_at: new Date()
                }
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Rol actualizado correctamente",
            usuario: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// DESACTIVAR USUARIO
// ==========================

export const desactivarUsuario = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await actualizarUsuario(
                id,
                {
                    activo: false,
                    updated_at: new Date()
                }
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Usuario desactivado correctamente",
            usuario: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};


// ==========================
// ACTIVAR USUARIO
// ==========================

export const activarUsuario = async (req, res) => {

    try {

        const { id } = req.params;

        const { data, error } =
            await actualizarUsuario(
                id,
                {
                    activo: true,
                    updated_at: new Date()
                }
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Usuario activado correctamente",
            usuario: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};