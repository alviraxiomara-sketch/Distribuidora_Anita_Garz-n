import { supabase } from "../config/supabase.js";

// ==========================
// CREAR NOTIFICACIÓN
// ==========================

export const crearNotificacion = async (
    notificacion
) => {

    const { data, error } =
        await supabase
            .from("notificaciones")
            .insert(notificacion)
            .select()
            .single();

    return { data, error };

};


// ==========================
// OBTENER NOTIFICACIONES
// POR USUARIO
// ==========================

export const obtenerNotificacionesUsuario =
async (id_usuario) => {

    const { data, error } =
        await supabase
            .from("notificaciones")
            .select("*")
            .eq(
                "id_usuario",
                id_usuario
            )
            .order(
                "fecha_envio",
                {
                    ascending: false
                }
            );

    return { data, error };

};


// ==========================
// OBTENER NOTIFICACIÓN
// ==========================

export const obtenerNotificacionPorId =
async (id_notificacion) => {

    const { data, error } =
        await supabase
            .from("notificaciones")
            .select("*")
            .eq(
                "id_notificacion",
                id_notificacion
            )
            .maybeSingle();

    return { data, error };

};


// ==========================
// MARCAR COMO LEÍDA
// ==========================

export const marcarLeida = async (
    id_notificacion
) => {

    const { data, error } =
        await supabase
            .from("notificaciones")
            .update({
                leida: true
            })
            .eq(
                "id_notificacion",
                id_notificacion
            )
            .select()
            .single();

    return { data, error };

};

// ==========================
// ELIMINAR NOTIFICACIÓN
// ==========================

export const eliminarNotificacion = async (
    id_notificacion
) => {

    const { data, error } =
        await supabase
            .from("notificaciones")
            .delete()
            .eq(
                "id_notificacion",
                id_notificacion
            )
            .select()
            .single();

    return { data, error };

};