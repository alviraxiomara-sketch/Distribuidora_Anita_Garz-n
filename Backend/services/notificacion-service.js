import {crearNotificacion} from "../models/notificacion-model.js";


// ==========================
// CREAR NOTIFICACIÓN
// ==========================

export const enviarNotificacion = async (

    id_usuario,

    titulo,

    mensaje

) => {

    try {

        await crearNotificacion({

            id_usuario,

            titulo,

            mensaje,

            leida: false

        });

    } catch (error) {

        console.error(
            "Error creando notificación:",
            error.message
        );
    }

};