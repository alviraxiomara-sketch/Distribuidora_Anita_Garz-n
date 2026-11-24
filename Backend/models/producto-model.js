import { supabase } from "../config/supabase.js";
 
// ==========================
// CREAR PRODUCTO
// ==========================
 
export const crearProducto = async (producto) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .insert(producto)
            .select()
            .single();
 
    return { data, error };
};
 
 
// ==========================
// OBTENER TODOS LOS PRODUCTOS
// ==========================
 
export const obtenerProductos = async () => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .select(`
                id_producto,
                id_categoria,
                nombre,
                presentacion,
                tapa,
                tipo,
                precio_detal,
                precio_mayorista,
                imagen_url,
                activo,
                created_at,
                updated_at,
                cantidad_minima_mayorista,
                categorias (
                    id_categoria,
                    nombre
                )
            `)
            .order("id_producto", {
                ascending: true
            });
 
    return { data, error };
};
 
 
// ==========================
// OBTENER PRODUCTO POR ID
// ==========================
 
export const obtenerProductoPorId = async (id_producto) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .select(`
                id_producto,
                id_categoria,
                nombre,
                presentacion,
                tapa,
                tipo,
                precio_detal,
                precio_mayorista,
                imagen_url,
                activo,
                created_at,
                updated_at,
                cantidad_minima_mayorista,
                categorias (
                    id_categoria,
                    nombre
                )
            `)
            .eq("id_producto", id_producto)
            .maybeSingle();
 
    return { data, error };
};
 
 
// ==========================
// OBTENER PRODUCTOS POR CATEGORÍA
// ==========================
 
export const obtenerProductosPorCategoria = async (id_categoria) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .select(`
                id_producto,
                id_categoria,
                nombre,
                presentacion,
                tapa,
                tipo,
                precio_detal,
                precio_mayorista,
                imagen_url,
                activo,
                created_at,
                updated_at,
                cantidad_minima_mayorista
            `)
            .eq("id_categoria", id_categoria)
            .order("nombre", {
                ascending: true
            });
 
    return { data, error };
};
 
 
// ==========================
// BUSCAR PRODUCTOS POR NOMBRE
// ==========================
 
export const buscarProductosPorNombre = async (nombre) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .select(`
                id_producto,
                id_categoria,
                nombre,
                presentacion,
                tapa,
                tipo,
                precio_detal,
                precio_mayorista,
                imagen_url,
                activo,
                created_at,
                updated_at,
                cantidad_minima_mayorista
            `)
            .ilike("nombre", `%${nombre}%`)
            .order("nombre", {
                ascending: true
            });
 
    return { data, error };
};
 
 
// ==========================
// ACTUALIZAR PRODUCTO
// ==========================
 
export const actualizarProducto = async (
    id_producto,
    datosActualizados
) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .update(datosActualizados)
            .eq("id_producto", id_producto)
            .select()
            .single();
 
    return { data, error };
};
 
 
// ==========================
// DESACTIVAR PRODUCTO
// ==========================
export const desactivarProducto = async (id_producto) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .update({
                activo: false,
                updated_at: new Date()
            })
            .eq("id_producto", id_producto)
            .select()
            .single();
 
    return { data, error };
};
 
 
// ==========================
// ACTIVAR PRODUCTO
// ==========================
export const activarProducto = async (id_producto) => {
 
    const { data, error } =
        await supabase
            .from("productos")
            .update({
                activo: true,
                updated_at: new Date()
            })
            .eq("id_producto", id_producto)
            .select()
            .single();
 
    return { data, error };
};


// ==========================
// ELIMINAR PRODUCTO (BORRADO REAL)
// ==========================
// Borra primero el inventario del producto y luego el producto.
// Si el producto tiene pedidos / movimientos asociados, la base de datos
// lo rechaza (error 23503) y se restaura el inventario para no perder el stock.

export const eliminarProducto = async (id_producto) => {

    const { data: inventario } =
        await supabase
            .from("inventario")
            .select("*")
            .eq("id_producto", id_producto)
            .maybeSingle();

    if (inventario) {
        const { error: errorInv } =
            await supabase
                .from("inventario")
                .delete()
                .eq("id_producto", id_producto);

        if (errorInv) {
            return { data: null, error: errorInv };
        }
    }

    const { data, error } =
        await supabase
            .from("productos")
            .delete()
            .eq("id_producto", id_producto)
            .select();

    if (error && inventario) {
        // Restaurar el inventario porque el producto no se pudo borrar
        await supabase.from("inventario").insert(inventario);
    }

    return { data, error };
};