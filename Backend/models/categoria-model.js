import { supabase } from "../config/supabase.js";

// ==========================
// CREAR CATEGORÍA
// ==========================

export const crearCategoria = async (categoria) => {

    const { data, error } =
        await supabase
            .from("categorias")
            .insert(categoria)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER TODAS LAS CATEGORÍAS
// ==========================

export const obtenerCategorias = async () => {

    const { data, error } =
        await supabase
            .from("categorias")
            .select(`
                id_categoria,
                nombre,
                descripcion,
                activo,
                created_at,
                updated_at
            `)
            .order("id_categoria", {
                ascending: true
            });

    return { data, error };
};


// ==========================
// OBTENER CATEGORÍA POR ID
// ==========================

export const obtenerCategoriaPorId = async (id_categoria) => {

    const { data, error } =
        await supabase
            .from("categorias")
            .select(`
                id_categoria,
                nombre,
                descripcion,
                activo,
                created_at,
                updated_at
            `)
            .eq("id_categoria", id_categoria)
            .maybeSingle();

    return { data, error };
};


// ==========================
// ACTUALIZAR CATEGORÍA
// ==========================

export const actualizarCategoria = async (
    id_categoria,
    datosActualizados
) => {

    const { data, error } =
        await supabase
            .from("categorias")
            .update(datosActualizados)
            .eq("id_categoria", id_categoria)
            .select()
            .single();

    return { data, error };
};


// ==========================
// DESACTIVAR CATEGORÍA
// ==========================

export const desactivarCategoria = async (id_categoria) => {

    const { data, error } =
        await supabase
            .from("categorias")
            .update({
                activo: false,
                updated_at: new Date()
            })
            .eq("id_categoria", id_categoria)
            .select()
            .single();

    return { data, error };
};

// ==========================
// OBTENER CATEGORÍA POR NOMBRE
// ==========================

export const obtenerCategoriaPorNombre = async (nombre) => {

    const { data, error } =
        await supabase
            .from("categorias")
            .select("*")
            .ilike("nombre", nombre)
            .maybeSingle();

    return { data, error };
};