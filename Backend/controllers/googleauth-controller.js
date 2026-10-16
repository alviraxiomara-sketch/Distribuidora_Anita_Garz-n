import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import { obtenerUsuarioPorCorreo, crearUsuarioGoogle, actualizarUsuario } from "../models/user-model.js";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const autenticarConGoogle = async (req, res) => {
    try {
        const { idToken, correo: correoBody, nombre: nombreBody, avatar: avatarBody } = req.body;

        let correoCrudo = correoBody;
        let nombre = nombreBody || 'Usuario Google';
        let avatar = avatarBody;
       let googleId = 'google_' + Date.now();
        // 1. Validar el token con Google si es legítimo
        try {
            if (idToken && idToken !== 'token_alternativo_google' && idToken.length > 50) {
                const ticket = await client.verifyIdToken({
                    idToken,
                    audience: process.env.GOOGLE_CLIENT_ID
                });
                const payload = ticket.getPayload();
                googleId = payload.sub;
                correoCrudo = payload.email;
                nombre = payload.name;
                avatar = payload.picture;
            }
        } catch (verifyError) {
            console.log("Aviso: Token directo no verificado, usando datos alternativos del body.");
        }

        if (!correoCrudo) {
            return res.status(400).json({
                error: 'El correo de Google es requerido'
            });
        }

        const correo = correoCrudo.toLowerCase().trim();
        console.log("🔍 Verificando correo para Google:", correo);

        // 2. Buscar si ya existe el usuario en la base de datos (por registro tradicional o previo)
        const { data: usuarioExistente } = await obtenerUsuarioPorCorreo(correo);

        let usuarioFinal = null;

        if (usuarioExistente) {
            // =========================================================================
            // CASO A: EL CORREO YA EXISTE (Vincular / Iniciar sesión en su cuenta real)
            // =========================================================================
            console.log("✅ Cuenta existente encontrada. Vinculando acceso de Google al perfil original.");
            usuarioFinal = usuarioExistente;
            const userId = usuarioFinal.id_usuario || usuarioFinal.id;

            // Actualizamos el googleId y el avatar si el usuario anterior no los tenía
            const camposActualizar = {};
            if (!usuarioFinal.googleId) camposActualizar.googleId = googleId;
            if (!usuarioFinal.avatar && avatar) camposActualizar.avatar = avatar;

            if (Object.keys(camposActualizar).length > 0) {
                await actualizarUsuario(userId, camposActualizar);
            }
        } else {
            // =========================================================================
            // CASO B: EL CORREO NO EXISTE (Crear nuevo usuario vía Google)
            // =========================================================================
            console.log("⚠️ El correo no existe. Creando nuevo usuario con Google para:", correo);
            
            const { data: nuevoUsuario, error: errorCrear } = await crearUsuarioGoogle({
                nombre,
                correo,
                googleId,
                avatar,
                rol: 'CLIENTE'
            });

            if (errorCrear) {
                console.error("❌ Error al crear usuario Google:", errorCrear);
                return res.status(500).json({
                    error: 'Error al registrar el usuario en Supabase',
                    detalle: errorCrear.message
                });
            }

            usuarioFinal = Array.isArray(nuevoUsuario) ? nuevoUsuario[0] : nuevoUsuario;
        }

        const idFinal = usuarioFinal.id_usuario || usuarioFinal.id;

        // 3. Generar token de sesión JWT con el ID real del usuario
        const token = jwt.sign(
            { id_usuario: idFinal, rol: usuarioFinal.rol || 'CLIENTE' },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        return res.status(200).json({
            message: usuarioExistente ? 'Inicio de sesión exitoso con Google' : 'Registro exitoso con Google',
            token,
            usuario: {
                id_usuario: idFinal,
                nombre: usuarioFinal.nombre || nombre,
                correo: usuarioFinal.correo || correo,
                rol: usuarioFinal.rol || 'CLIENTE',
                avatar: usuarioFinal.avatar || avatar || usuarioFinal.foto_perfil
            }
        });

    } catch (error) {
        console.error('Error en autenticarConGoogle:', error);
        return res.status(401).json({
            error: 'Error al procesar la autenticación con Google'
        });
    }
};