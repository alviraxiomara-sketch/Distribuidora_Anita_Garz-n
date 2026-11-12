import { supabase } from "../config/supabase.js";

// ==========================
// OBTENER CARRITO DEL USUARIO
// ==========================
// Usa "*" para no fallar si alguna columna no existe.
// Si por error hay más de un carrito del usuario, toma el más antiguo.

export const obtenerCarritoPorUsuario = async (id_usuario) => {

    const { data, error } =
        await supabase
            .from("carrito")
            .select(`
                *,
                detalle_carrito (
                    *,
                    productos (*)
                )
            `)
            .eq("id_usuario", id_usuario)
            .order("id_carrito", { ascending: true })
            .limit(1)
            .maybeSingle();

    return { data, error };
};


// ==========================
// CREAR CARRITO
// ==========================

export const crearCarrito = async (carrito) => {

    const { data, error } =
        await supabase
            .from("carrito")
            .insert(carrito)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER CARRITO POR ID
// ==========================

export const obtenerCarritoPorId = async (id_carrito) => {

    const { data, error } =
        await supabase
            .from("carrito")
            .select(`
                *,
                detalle_carrito (
                    *,
                    productos (*)
                )
            `)
            .eq("id_carrito", id_carrito)
            .maybeSingle();

    return { data, error };
};


// ==========================
// AGREGAR PRODUCTO AL CARRITO
// ==========================

export const agregarDetalleCarrito = async (detalle) => {

    const { data, error } =
        await supabase
            .from("detalle_carrito")
            .insert(detalle)
            .select()
            .single();

    return { data, error };
};


// ==========================
// BUSCAR PRODUCTO EN CARRITO
// ==========================

export const obtenerDetallePorProducto = async (
    id_carrito,
    id_producto
) => {

    const { data, error } =
        await supabase
            .from("detalle_carrito")
            .select("*")
            .eq("id_carrito", id_carrito)
            .eq("id_producto", id_producto)
            .maybeSingle();

    return { data, error };
};


// ==========================
// ACTUALIZAR DETALLE
// ==========================

export const actualizarDetalleCarrito = async (
    id_detalle_carrito,
    datosActualizados
) => {

    const { data, error } =
        await supabase
            .from("detalle_carrito")
            .update(datosActualizados)
            .eq("id_detalle_carrito", id_detalle_carrito)
            .select()
            .single();

    return { data, error };
};


// ==========================
// ELIMINAR PRODUCTO DEL CARRITO
// ==========================

export const eliminarDetalleCarrito = async (id_detalle_carrito) => {

    const { data, error } =
        await supabase
            .from("detalle_carrito")
            .delete()
            .eq("id_detalle_carrito", id_detalle_carrito)
            .select()
            .single();

    return { data, error };
};