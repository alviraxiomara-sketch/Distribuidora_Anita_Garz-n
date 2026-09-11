import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import {crearUsuario, obtenerUsuarioPorCorreo, obtenerUsuarioCompletoPorId, obtenerUsuarioPorId, actualizarUsuario, actualizarPassword} from "../models/user-model.js";

// ==========================
// REGISTRO
// ==========================

export const registro = async (req, res) => {

    try {

        const {
            nombre,
            correo,
            telefono,
            direccion,
            password
        } = req.body;

        // Validar campos obligatorios

        if (!nombre || !correo || !password) {
            return res.status(400).json({
                error: "Nombre, correo y contraseña son obligatorios"
            });
        }

        // Verificar si ya existe

        const { data: usuarioExiste } =
            await obtenerUsuarioPorCorreo(correo);

        if (usuarioExiste) {
            return res.status(400).json({
                error: "El correo ya está registrado"
            });
        }

        // Encriptar contraseña

        const password_hash =
            await bcrypt.hash(password, 10);

        // Crear usuario

        const nuevoUsuario = {
            nombre,
            correo,
            telefono: telefono || null,
            direccion: direccion || null,
            password_hash,
            rol: "CLIENTE",
            activo: true
        };

        const { data, error } =
            await crearUsuario(nuevoUsuario);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(201).json({
            mensaje: "Usuario registrado correctamente",
            usuario: {
                id_usuario: data.id_usuario,
                nombre: data.nombre,
                correo: data.correo,
                rol: data.rol
            }
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};



// ==========================
// LOGIN
// ==========================

export const login = async (req, res) => {

    try {

        const { correo, password } = req.body;

        if (!correo || !password) {
            return res.status(400).json({
                error: "Correo y contraseña son obligatorios"
            });
        }

        const { data: usuario } =
            await obtenerUsuarioPorCorreo(correo);

        if (!usuario) {
            return res.status(404).json({
                error: "Usuario no encontrado"
            });
        }

        if (!usuario.activo) {
            return res.status(403).json({
                error: "Usuario inactivo"
            });
        }

        const passwordValida =
            await bcrypt.compare(
                password,
                usuario.password_hash
            );

        if (!passwordValida) {
            return res.status(400).json({
                error: "Contraseña incorrecta"
            });
        }

        const token = jwt.sign(
            {
                id_usuario: usuario.id_usuario,
                nombre: usuario.nombre,
                correo: usuario.correo,
                rol: usuario.rol
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "24h"
            }
        );

        return res.status(200).json({
            mensaje: "Inicio de sesión exitoso",
            token,
            usuario: {
                id_usuario: usuario.id_usuario,
                nombre: usuario.nombre,
                correo: usuario.correo,
                rol: usuario.rol
            }
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};



// ==========================
// OBTENER PERFIL
// ==========================

export const obtenerPerfil = async (req, res) => {

    try {

        const id_usuario = req.usuario.id_usuario;

        const { data, error } =
            await obtenerUsuarioPorId(id_usuario);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};



// ==========================
// ACTUALIZAR PERFIL
// ==========================

export const actualizarPerfil = async (req, res) => {

    try {

        const id_usuario = req.usuario.id_usuario;

        const {
            nombre,
            telefono,
            direccion,
            foto_perfil
        } = req.body;

        const { data, error } =
            await actualizarUsuario(
                id_usuario,
                {
                    nombre,
                    telefono,
                    direccion,
                    foto_perfil,
                    updated_at: new Date()
                }
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Perfil actualizado correctamente",
            usuario: data
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};



// ==========================
// CAMBIAR CONTRASEÑA
// ==========================

export const cambiarPassword = async (req, res) => {

    try {

        const id_usuario = req.usuario.id_usuario;
        

        const {
            passwordActual,
            passwordNueva
        } = req.body;

        if (!passwordActual || !passwordNueva) {
            return res.status(400).json({
                error: "Debe enviar ambas contraseñas"
            });
        }

        const { data: usuario } =
        await obtenerUsuarioCompletoPorId(id_usuario);

        const passwordValida =
            await bcrypt.compare(
                passwordActual,
                usuario.password_hash
            );

        if (!passwordValida) {
            return res.status(400).json({
                error: "La contraseña actual no es correcta"
            });
        }

        const nuevoHash =
            await bcrypt.hash(passwordNueva, 10);

        const { error } =
            await actualizarPassword(
                id_usuario,
                nuevoHash
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Contraseña actualizada correctamente"
        });

    } catch (error) {

        return res.status(500).json({
            error: error.message
        });

    }
};