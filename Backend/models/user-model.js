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
        activo,
        foto_perfil 
    } = usuario;

    const { data, error } = await supabase
        .from("usuarios")
        .insert([
            {
                nombre,
                correo: correo ? correo.toLowerCase().trim() : correo,
                password_hash,
                rol,
                telefono,
                direccion,
                activo,
                foto_perfil
            }
        ])
        .select("id_usuario, nombre, correo, telefono, direccion, foto_perfil, rol")
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

// Buscar por correo (Normalizado)
export const obtenerUsuarioPorCorreo = async (correo) => {
    const correoLimpio = correo ? correo.toLowerCase().trim() : '';
    const { data, error } = await supabase
        .from("usuarios")
        .select("*")
        .eq("correo", correoLimpio)
        .maybeSingle();

    return { data, error };
};

// Obtener usuario existente por correo (versión para autenticación con Google)
export const obtenerPorEmail = async (correo) => {
    const correoLimpio = correo ? correo.toLowerCase().trim() : '';
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('correo', correoLimpio)
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

// Función específica para los usuarios autenticados con Google (CORREGIDA)
export const crearUsuarioGoogle = async ({ nombre, correo, email, googleId, avatar = null, rol = 'CLIENTE' }) => {
    const correoCrudo = correo || email;
    const correoFinal = correoCrudo ? correoCrudo.toLowerCase().trim() : correoCrudo;

    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            nombre,
            correo: correoFinal,
            password_hash: null,
            rol,
            isVerified: true,
            googleId,
            foto_perfil: avatar // <--- Asignamos correctamente el avatar a la columna real
        })
        .select('id_usuario, nombre, correo, rol, foto_perfil') // <--- Seleccionamos la columna real
        .single();

    return { data, error };
};

// Actualizar usuario (CORREGIDO PARA MAPEAR AVATAR A FOTO_PERFIL)
export const actualizarUsuario = async (id_usuario, campos) => {
    if (campos.correo) {
        campos.correo = campos.correo.toLowerCase().trim();
    }
    
    // Si la petición trae 'avatar', lo convertimos a 'foto_perfil' que es como se llama en Supabase
    if (campos.avatar !== undefined) {
        campos.foto_perfil = campos.avatar;
        delete campos.avatar; // Borramos 'avatar' para que Supabase no lance error de columna inexistente
    }

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