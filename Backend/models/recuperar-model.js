import { supabase } from "../config/supabase.js";

// ==========================
// CREAR CÓDIGO
// ==========================

export const crearCodigoRecuperacion = async (

    id_usuario,
    codigo

) => {

    const fecha_expiracion =
        new Date(
            Date.now() + 15 * 60 * 1000
        );

    const { data, error } =
        await supabase
            .from("codigos_recuperacion")
            .insert({

                id_usuario,

                codigo,

                fecha_expiracion

            })
            .select()
            .single();

    return { data, error };

};


// ==========================
// BUSCAR CÓDIGO VÁLIDO
// ==========================

export const obtenerCodigoValido = async (

    id_usuario,
    codigo

) => {

    const { data, error } =
        await supabase
            .from("codigos_recuperacion")
            .select("*")
            .eq(
                "id_usuario",
                id_usuario
            )
            .eq(
                "codigo",
                codigo
            )
            .eq(
                "usado",
                false
            );

    if (error) {

        return {
            data: null,
            error
        };

    }

    const codigoValido =
        data?.find(

            registro =>

                new Date(
                    registro.fecha_expiracion
                ) > new Date()

        );

    return {

        data:
            codigoValido || null,

        error: null

    };

};


// ==========================
// MARCAR COMO USADO
// ==========================

export const marcarCodigoComoUsado = async (

    id_codigo

) => {

    const { data, error } =
        await supabase
            .from("codigos_recuperacion")
            .update({

                usado: true

            })
            .eq(
                "id_codigo",
                id_codigo
            )
            .select()
            .single();

    return { data, error };

};

// ==========================
// INVALIDAR CÓDIGOS ANTERIORES
// ==========================

export const invalidarCodigosAnteriores = async (
    id_usuario
) => {

    const { data, error } =
        await supabase
            .from("codigos_recuperacion")
            .update({
                usado: true
            })
            .eq(
                "id_usuario",
                id_usuario
            )
            .eq(
                "usado",
                false
            );

    return { data, error };

};