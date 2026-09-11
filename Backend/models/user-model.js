import { supabase } from "../config/supabase.js";

// Crear usuario
export const crearUsuario = async (usuario) => {
    const { 
        nombre, 
        correo, 
        password_hash, 
        rol, 
        telefono, 
        direccion, 
        activo 
    } = usuario;

    const { data, error } = await supabase
        .from("usuarios")
        .insert([
            {
                nombre,
                correo,
                password_hash,
                rol,
                telefono,
                direccion,
                activo
            }
        ])
        .select("id_usuario, nombre, correo, rol")
        .single();

    return { data, error };
};

// Obtener todos los usuarios
export const obtenerUsuarios = async () => {
    const { data, error } = await supabase
        .from("usuarios")
        .select(`
            id_usuario,
            nombre,
            correo,
            telefono,
            direccion,
            foto_perfil,
            rol,
            activo,
            fecha_registro
        `);

    return { data, error };
};

// Buscar por correo
export const obtenerUsuarioPorCorreo = async (correo) => {
    const { data, error } = await supabase
        .from("usuarios")
        .select("*")
        .eq("correo", correo)
        .maybeSingle();

    return { data, error };
};

// 1. Obtener usuario existente por correo (versión para autenticación con Google)
export const obtenerPorEmail = async (correo) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('correo', correo)
        .maybeSingle();

    return { data, error };
};

// Buscar por ID
export const obtenerUsuarioPorId = async (id_usuario) => {
    const { data, error } = await supabase
        .from("usuarios")
        .select(`
            id_usuario,
            nombre,
            correo,
            telefono,
            direccion,
            foto_perfil,
            rol,
            activo,
            fecha_registro
        `)
        .eq("id_usuario", id_usuario)
        .single();

    return { data, error };
};

// 2. Función específica para los usuarios autenticados con Google
export const crearUsuarioGoogle = async ({ nombre, correo, email, googleId, avatar = null, rol = 'CLIENTE' }) => {
    const correoFinal = correo || email;

    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            nombre,
            correo: correoFinal,
            password_hash: null,
            rol,
            isVerified: true,
            googleId,
            avatar
        })
        .select('id_usuario, nombre, correo, rol, avatar')
        .single();

    return { data, error };
};

// Actualizar usuario
export const actualizarUsuario = async (id_usuario, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id_usuario', id_usuario)
        .select()
        .single();

    return { data, error };
};

// Actualizar contraseña
export const actualizarPassword = async (
    id_usuario,
    password_hash
) => {

    const { data, error } = await supabase
        .from("usuarios")
        .update({
            password_hash
        })
        .eq("id_usuario", id_usuario)
        .select()
        .single();

    return { data, error };
};

// Obtener usuario completo para procesos internos
export const obtenerUsuarioCompletoPorId = async (id_usuario) => {

    const { data, error } = await supabase
        .from("usuarios")
        .select("*")
        .eq("id_usuario", id_usuario)
        .single();

    return { data, error };
};