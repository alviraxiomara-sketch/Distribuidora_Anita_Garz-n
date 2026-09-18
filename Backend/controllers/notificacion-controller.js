import {obtenerNotificacionesUsuario, obtenerNotificacionPorId, marcarLeida, eliminarNotificacion} from "../models/notificacion-model.js";


// ==========================
// LISTAR MIS NOTIFICACIONES
// ==========================

export const listarMisNotificaciones =
async (req, res) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;

        const { data, error } =
            await obtenerNotificacionesUsuario(
                id_usuario
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
// MARCAR COMO LEÍDA
// ==========================

export const marcarComoLeida =
async (req, res) => {

    try {

        const { id } =
            req.params;

        const {
            data: notificacion,
            error
        } =
        await obtenerNotificacionPorId(
            id
        );

        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }

        if (!notificacion) {

            return res.status(404).json({
                error:
                "Notificación no encontrada"
            });

        }

        if (
            Number(
                notificacion.id_usuario
            )
            !==
            Number(
                req.usuario.id_usuario
            )
        ) {

            return res.status(403).json({
                error:
                "No tiene permiso"
            });

        }

        const {
            data,
            error: errorUpdate
        } = await marcarLeida(id);

        if (errorUpdate) {

            return res.status(500).json({
                error:
                errorUpdate.message
            });

        }

        return res.status(200).json({

            mensaje:
            "Notificación marcada como leída",

            notificacion: data

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }

};

// ==========================
// ELIMINAR NOTIFICACIÓN
// ==========================

export const eliminar =
async (req, res) => {

    try {

        const { id } =
            req.params;

        const {
            data: notificacion,
            error
        } =
        await obtenerNotificacionPorId(
            id
        );

        if (error) {

            return res.status(500).json({
                error: error.message
            });

        }

        if (!notificacion) {

            return res.status(404).json({
                error:
                "Notificación no encontrada"
            });

        }

        if (
            Number(
                notificacion.id_usuario
            )
            !==
            Number(
                req.usuario.id_usuario
            )
        ) {

            return res.status(403).json({
                error:
                "No tiene permiso"
            });

        }

        const {
            data,
            error: errorDelete
        } = await eliminarNotificacion(id);

        if (errorDelete) {

            return res.status(500).json({
                error:
                errorDelete.message
            });

        }

        return res.status(200).json({

            mensaje:
            "Notificación eliminada correctamente",

            notificacion: data

        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }

};