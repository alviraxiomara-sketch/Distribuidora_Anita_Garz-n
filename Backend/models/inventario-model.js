import { supabase } from "../config/supabase.js";

// ==========================
// OBTENER TODO EL INVENTARIO
// ==========================

export const obtenerInventario = async () => {

    const { data, error } =
        await supabase
            .from("inventario")
            .select(`
                id_inventario,
                id_producto,
                stock_actual,
                stock_minimo,
                updated_at,
                productos (
                    id_producto,
                    nombre,
                    presentacion,
                    precio_detal,
                    precio_mayorista,
                    imagen_url,
                    activo
                )
            `)
            .order("id_inventario", {
                ascending: true
            });

    return { data, error };
};


// ==========================
// OBTENER INVENTARIO POR PRODUCTO
// ==========================

export const obtenerInventarioPorProducto = async (
    id_producto
) => {

    const { data, error } =
        await supabase
            .from("inventario")
            .select(`
                id_inventario,
                id_producto,
                stock_actual,
                stock_minimo,
                updated_at,
                productos (
                    id_producto,
                    nombre,
                    presentacion,
                    precio_detal,
                    precio_mayorista,
                    imagen_url,
                    activo
                )
            `)
            .eq("id_producto", id_producto)
            .maybeSingle();

    return { data, error };
};


// ==========================
// CREAR INVENTARIO
// ==========================

export const crearInventario = async (inventario) => {

    const { data, error } =
        await supabase
            .from("inventario")
            .insert(inventario)
            .select()
            .single();

    return { data, error };
};


// ==========================
// ACTUALIZAR STOCK
// ==========================

export const actualizarStock = async (
    id_producto,
    stock_actual
) => {

    const { data, error } =
        await supabase
            .from("inventario")
            .update({
                stock_actual,
                updated_at: new Date()
            })
            .eq("id_producto", id_producto)
            .select()
            .single();

    return { data, error };
};


// ==========================
// ACTUALIZAR STOCK MÍNIMO
// ==========================

export const actualizarStockMinimo = async (
    id_producto,
    stock_minimo
) => {

    const { data, error } =
        await supabase
            .from("inventario")
            .update({
                stock_minimo,
                updated_at: new Date()
            })
            .eq("id_producto", id_producto)
            .select()
            .single();

    return { data, error };
};


// ==========================
// REGISTRAR MOVIMIENTO
// ==========================

export const registrarMovimiento = async (
    movimiento
) => {

    const { data, error } =
        await supabase
            .from("movimientos_inventario")
            .insert(movimiento)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER MOVIMIENTOS
// ==========================

export const obtenerMovimientos = async () => {

    const { data, error } =
        await supabase
            .from("movimientos_inventario")
            .select(`
                id_movimiento,
                id_producto,
                tipo_movimiento,
                cantidad,
                observacion,
                fecha_movimiento,
                id_usuario,
                productos (
                    id_producto,
                    nombre
                ),
                usuarios (
                    id_usuario,
                    nombre,
                    correo
                )
            `)
            .order("fecha_movimiento", {
                ascending: false
            });

    return { data, error };
};


// ==========================
// OBTENER MOVIMIENTOS POR PRODUCTO
// ==========================

export const obtenerMovimientosPorProducto = async (
    id_producto
) => {

    const { data, error } =
        await supabase
            .from("movimientos_inventario")
            .select(`
                id_movimiento,
                id_producto,
                tipo_movimiento,
                cantidad,
                observacion,
                fecha_movimiento,
                id_usuario,
                usuarios (
                    id_usuario,
                    nombre,
                    correo
                )
            `)
            .eq("id_producto", id_producto)
            .order("fecha_movimiento", {
                ascending: false
            });

    return { data, error };
};