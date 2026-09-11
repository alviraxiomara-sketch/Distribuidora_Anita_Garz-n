import { supabase } from "../config/supabase.js";

// ==========================
// CREAR PAGO
// ==========================

export const crearPago = async (pago) => {

    const { data, error } =
        await supabase
            .from("pagos")
            .insert(pago)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER PAGO POR PEDIDO
// ==========================

export const obtenerPagoPorPedido = async (
    id_pedido
) => {

    const { data, error } =
        await supabase
            .from("pagos")
            .select(`
                id_pago,
                id_pedido,
                metodo_pago,
                valor,
                estado,
                referencia,
                fecha_pago,
                created_at,
                updated_at
            `)
            .eq("id_pedido", id_pedido)
            .maybeSingle();

    return { data, error };
};


// ==========================
// OBTENER PAGO POR ID
// ==========================

export const obtenerPagoPorId = async (
    id_pago
) => {

    const { data, error } =
        await supabase
            .from("pagos")
            .select(`
                id_pago,
                id_pedido,
                metodo_pago,
                valor,
                estado,
                referencia,
                fecha_pago,
                created_at,
                updated_at
            `)
            .eq("id_pago", id_pago)
            .maybeSingle();

    return { data, error };
};


// ==========================
// ACTUALIZAR PAGO
// ==========================

export const actualizarPago = async (
    id_pago,
    datosActualizados
) => {

    const { data, error } =
        await supabase
            .from("pagos")
            .update({
                ...datosActualizados,
                updated_at: new Date()
            })
            .eq("id_pago", id_pago)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER TODOS LOS PAGOS
// ==========================

export const obtenerTodosLosPagos = async () => {

    const { data, error } =
        await supabase
            .from("pagos")
            .select(`
                id_pago,
                id_pedido,
                metodo_pago,
                valor,
                estado,
                referencia,
                fecha_pago,
                created_at,
                updated_at,
                pedidos (
                    id_pedido,
                    id_usuario,
                    direccion_entrega,
                    telefono_contacto,
                    estado,
                    total,
                    fecha_pedido
                )
            `)
            .order("created_at", {
                ascending: false
            });

    return { data, error };
};