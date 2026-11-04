import { BrevoClient } from '@getbrevo/brevo';

const brevo = new BrevoClient({
  apiKey: process.env.BREVO_API_KEY,
});

export const enviarCodigoVerificacion = async (correo, nombre, codigo) => {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: "¡Recuperación de contraseña - Distribuidora Anita!",
      sender: {
        name: "Distribuidora Anita",
        email: process.env.EMAIL_USER
      },
      to: [
        {
          email: correo,
          name: nombre
        }
      ],
      htmlContent: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
          <h2 style="color: #4a2c11; text-align: center;">¡Hola, ${nombre}!</h2>
          <p>Has solicitado restablecer tu contraseña en <strong>Distribuidora Anita</strong>.</p>
          <p>Para continuar con el proceso, ingresa el siguiente código de verificación:</p>
          <div style="background-color: #f7f3ee; color: #4a2c11; padding: 15px; font-size: 26px; font-weight: bold; letter-spacing: 6px; text-align: center; border-radius: 6px; margin: 20px 0; border: 1px dashed #c2a68d;">
            ${codigo}
          </div>
          <p style="font-size: 13px; color: #777;">Este código vencerá en <strong>15 minutos</strong>.</p>
          <p style="font-size: 12px; color: #999; margin-top: 20px;">Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
        </div>
      `
    });

    return result;
  } catch (error) {
    console.error("Error enviando correo con Brevo:", error);
    throw error;
  }
};