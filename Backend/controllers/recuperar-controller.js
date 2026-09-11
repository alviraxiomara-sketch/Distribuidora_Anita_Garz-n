import bcrypt from "bcrypt";
import nodemailer from "nodemailer";
import {crearCodigoRecuperacion, obtenerCodigoValido, marcarCodigoComoUsado, invalidarCodigosAnteriores} from "../models/recuperar-model.js";
import {obtenerUsuarioPorCorreo, actualizarPassword} from "../models/user-model.js";

// ==========================
// CONFIGURAR NODEMAILER
// ==========================

const transporter =
    nodemailer.createTransport({

        service: "gmail",

        auth: {

            user:
                process.env.EMAIL_USER,

            pass:
                process.env.EMAIL_PASSWORD

        }

    });


// ==========================
// ENVIAR CÓDIGO
// ==========================

export const forgotPassword = async (
    req,
    res
) => {

    try {

        const {
            correo
        } = req.body;

        if (!correo) {

            return res.status(400).json({

                error:
                    "El correo es obligatorio"

            });

        }

        const {
            data: usuario,
            error
        } = await obtenerUsuarioPorCorreo(
            correo
        );

        if (error || !usuario) {

            return res.status(404).json({

                error:
                    "Usuario no encontrado"

            });

        }

        await invalidarCodigosAnteriores(
            usuario.id_usuario
        );

        const codigo =
            Math.floor(
                100000 +
                Math.random() * 900000
            );

        const {
            error: errorCodigo
        } = await crearCodigoRecuperacion(

            usuario.id_usuario,

            codigo

        );

        if (errorCodigo) {

            return res.status(500).json({

                error:
                    "Error creando código"

            });

        }

        await transporter.sendMail({

            from:
                process.env.EMAIL_USER,

            to:
                usuario.correo,

            subject:
                "Código de recuperación - Distribuidora Anita",

            html: `

                <div style="font-family: Arial; max-width:600px; margin:auto;">

                    <h2>
                        Recuperación de contraseña
                    </h2>

                    <p>
                        Hola ${usuario.nombre}
                    </p>

                    <p>
                        Tu código de recuperación es:
                    </p>

                    <h1 style="
                        color:#39A900;
                        font-size:40px;
                    ">
                        ${codigo}
                    </h1>

                    <p>
                        Este código expirará en 15 minutos.
                    </p>

                    <p>
                        No compartas este código con nadie.
                    </p>

                    <br>

                    <p>
                        Distribuidora Anita
                    </p>

                </div>

            `

        });

        return res.status(200).json({

            mensaje:
                "Código enviado correctamente"

        });

    } catch (error) {

        return res.status(500).json({

            error:
                error.message

        });

    }

};


// ==========================
// RESTABLECER CONTRASEÑA
// ==========================

export const resetPassword = async (
    req,
    res
) => {

    try {

        const {

            correo,
            codigo,
            passwordNueva

        } = req.body;

        if (

            !correo ||
            !codigo ||
            !passwordNueva

        ) {

            return res.status(400).json({

                error:
                    "Todos los campos son obligatorios"

            });

        }

        const {
            data: usuario
        } = await obtenerUsuarioPorCorreo(
            correo
        );

        if (!usuario) {

            return res.status(404).json({

                error:
                    "Usuario no encontrado"

            });

        }

        const {
            data: codigoValido,
            error: errorCodigo
        } = await obtenerCodigoValido(

            usuario.id_usuario,

            codigo

        );

        if (
            errorCodigo ||
            !codigoValido
        ) {

            return res.status(400).json({

                error:
                    "Código inválido o expirado"

            });

        }

        const nuevoHash =
            await bcrypt.hash(
                passwordNueva,
                10
            );

        const {
            error: errorPassword
        } = await actualizarPassword(

            usuario.id_usuario,

            nuevoHash

        );

        if (errorPassword) {

            return res.status(500).json({

                error:
                    errorPassword.message

            });

        }

        await marcarCodigoComoUsado(
            codigoValido.id_codigo
        );

        await transporter.sendMail({

            from:
                process.env.EMAIL_USER,

            to:
                usuario.correo,

            subject:
                "Contraseña actualizada",

            html: `

                <div style="font-family: Arial;">

                    <h2>
                        Contraseña actualizada
                    </h2>

                    <p>
                        Hola ${usuario.nombre}
                    </p>

                    <p>
                        Tu contraseña fue actualizada correctamente.
                    </p>

                    <p>
                        Si no realizaste este cambio,
                        comunícate inmediatamente con soporte.
                    </p>

                </div>

            `

        });

        return res.status(200).json({

            mensaje:
                "Contraseña actualizada correctamente"

        });

    } catch (error) {

        return res.status(500).json({

            error:
                error.message

        });

    }

};