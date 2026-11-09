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

export const enviarCorreoPedidoExitoso = async (correo, nombre, idPedido, total, metodoPago) => {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: `¡Pedido #${idPedido} confirmado - Distribuidora Anita!`,
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
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; background-color: #fdfdfd;">
          <h2 style="color: #063B5D; text-align: center;">¡Gracias por tu compra, ${nombre}!</h2>
          <p>Tu pedido <strong>#${idPedido}</strong> ha sido registrado con éxito en <strong>Distribuidora Anita</strong>.</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          <p><strong>Método de pago:</strong> ${metodoPago}</p>
          <p><strong>Total pagado:</strong> $${total}</p>
          <p style="margin-top: 20px;">Te estaremos notificando cuando tu pedido sea aprobado y empiece su proceso de entrega.</p>
          <p style="font-size: 12px; color: #777; margin-top: 30px; text-align: center;">Distribuidora Anita - Todos los derechos reservados.</p>
        </div>
      `
    });

    return result;
  } catch (error) {
    console.error("Error enviando correo de pedido con Brevo:", error);
    throw error;
  }
};