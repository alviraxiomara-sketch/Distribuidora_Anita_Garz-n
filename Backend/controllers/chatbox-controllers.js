import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearConDistribuidoraAnita = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `Distribuidora_sesion_${Date.now()}`;

    // 1. Obtener la carta desde Supabase
    const { data: productos, error: errorProductos } = await supabase
      .from("productos")
      .select("nombre, descripcion, precio_detal");

    if (errorProductos) {
      console.error("Error al consultar Supabase:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    if (!productos || productos.length === 0) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos bebidas registradas en la carta.",
      });
    }

    // 2. Armar catálogo para la IA
    const catalogoTexto = productos
      .map(
        (p) =>
          `- ${p.nombre}: $${Number(p.precio_detal).toLocaleString("es-CO")} COP | Descripción: ${p.descripcion}`
      )
      .join("\n");

    // 3. Traer los últimos mensajes de esta sesión
    const { data: previos } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje")
      .eq("sesion_id", idSesionValido)
      .order("created_at", { ascending: false })
      .limit(10);

    const historial = (previos || [])
      .reverse()
      .filter((m) => !m.mensaje.startsWith("Lo siento, esa solicitud no se puede realizar"))
      .map((m) => ({
        role: m.emisor === "user" ? "user" : "assistant",
        content: m.mensaje,
      }));

    const esPrimerMensaje = !previos || previos.length === 0;

    // 4. Regla de saludo condicional
    const reglaSaludo = esPrimerMensaje
      ? `Esta es la PRIMERA interacción. Si el cliente solo saluda, responde: "¡Hola! Bienvenido a Distribuidora Anita 🥤. ¿En qué antojo refrescante te podemos colaborar hoy?". Si en cambio pregunta algo directo, responde la pregunta sin saludar.`
      : `La conversación YA INICIÓ. NO saludes, NO digas "Hola" ni "Bienvenido" y NO te presentes de nuevo. Responde directo a lo que pregunta el cliente.`;

    // 5. Prompt del sistema
    const systemPrompt = `
Eres el asesor virtual de la Distribuidora "Distribuidora Anita".
Eres alegre, amable, refrescante y educado.

CATÁLOGO ACTUAL EN TIENDA:
${catalogoTexto}

ALCANCE:
- Solo puedes hablar de Distribuidora Anita: productos, precios, descripciones y disponibilidad según el catálogo de arriba.

SI ESTÁ PERMITIDO:
- Preguntas sobre productos, categorías (cervezas, rones, etc.), precios o características del catálogo.
- Mensajes con errores de ortografía: interpreta la intención y responde amablemente.

NO ESTÁ PERMITIDO:
- Temas ajenos a la distribuidora (matemáticas, programación, noticias, etc.).
- En esos casos responde únicamente:
  "Lo siento, esa solicitud no se puede realizar por este medio. Solo puedo ayudarte con los productos y precios de Distribuidora Anita 🥤. ¿Te muestro nuestro catálogo?"

REGLAS DE ATENCIÓN:
1. ${reglaSaludo}
2. Precios siempre en pesos colombianos ($ COP).
3. Texto plano sin tablas, sin asteriscos ni markdown.
`;

    // 6. Inferencia con Groq + Sistema de Respaldo (Fallback)
       const modelosAProbar = [
      "openai/gpt-oss-120b",
      "openai/gpt-oss-20b",
      "groq/compound-mini",
      "llama-3.3-70b-versatile",
      "llama-3.1-8b-instant"
    ];

    let respuestaTexto = null;

    for (const modelo of modelosAProbar) {
      try {
        const completion = await groq.chat.completions.create({
          model: modelo,
          messages: [
            { role: "system", content: systemPrompt },
            ...historial,
            { role: "user", content: mensaje },
          ],
          temperature: 0.1,
          max_tokens: 1500,
        });

        respuestaTexto = completion.choices[0]?.message?.content?.trim();
        if (respuestaTexto) {
          console.log(`Respuesta generada con éxito usando el modelo: ${modelo}`);
          break;
        }
      } catch (errModelo) {
        console.warn(`Falló el modelo ${modelo}: ${errModelo.message}. Intentando con el siguiente...`);
      }
    }

    if (!respuestaTexto) {
      respuestaTexto = "En este momento tenemos una alta demanda en el servicio de chat. Por favor intenta de nuevo en unos segundos.";
    }

    // 7. Guardar pregunta y respuesta en Supabase
    const registrosAInsertar = [
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "user",
        mensaje: mensaje.trim(),
      },
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "bot",
        mensaje: respuestaTexto,
      },
    ];

    const { error: errorInsert } = await supabase
      .from("mensajes_chat")
      .insert(registrosAInsertar);

    if (errorInsert) {
      console.error("Error guardando el historial en Supabase:", errorInsert.message);
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido,
    });
  } catch (error) {
    console.error("Error en Groq Chat Distribuidora:", error);
    return res.status(200).json({
      respuesta: "Ocurrió un inconveniente temporal con el servidor del chat. Intenta nuevamente en un momento.",
      sesionId: req.body.sesionId || `Distribuidora_sesion_${Date.now()}`
    });
  }
};

export const obtenerHistorialDistribuidora = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data: historial, error } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje, created_at")
      .eq("sesion_id", sesionId)
      .order("created_at", { ascending: true });

    if (error) {
      return res.status(500).json({ message: "Error al consultar historial", error: error.message });
    }

    return res.status(200).json({ historial: historial || [] });
  } catch (error) {
    return res.status(500).json({ message: "Error interno", error: error.message });
  }
};

export const eliminarHistorialDistribuidora = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data, error } = await supabase
      .from("mensajes_chat")
      .delete()
      .eq("sesion_id", sesionId)
      .select();

    if (error) {
      return res.status(500).json({ message: "Error al eliminar historial", error: error.message });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ message: "No se encontró historial para esa sesión" });
    }

    return res.status(200).json({
      mensaje: "Historial eliminado correctamente",
      mensajesEliminados: data.length,
    });
  } catch (error) {
    return res.status(500).json({ message: "Error interno", error: error.message });
  }
};