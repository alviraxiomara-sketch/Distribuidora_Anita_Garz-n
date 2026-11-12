import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

// ==========================
// CONFIGURACIÓN
// ==========================

// Cliente creado al primer uso (así no falla si el .env se carga tarde)
let groqClient = null;
const getGroq = () => {
  if (!groqClient) {
    groqClient = new Groq({
      apiKey: process.env.GROQ_API_KEY,
      timeout: 20000, // 20 s máximo por intento
      maxRetries: 0,  // los reintentos los manejamos nosotros con los modelos de respaldo
    });
  }
  return groqClient;
};

// Los modelos se pueden cambiar desde Render (variable GROQ_MODELS) sin tocar el código.
// Ejemplo: GROQ_MODELS=llama-3.3-70b-versatile,llama-3.1-8b-instant
// Si Groq retira un modelo, solo cambias esa variable y reinicias.
const MODELOS = (
  process.env.GROQ_MODELS || "llama-3.3-70b-versatile,llama-3.1-8b-instant"
)
  .split(",")
  .map((m) => m.trim())
  .filter(Boolean);

const MSG_NO_PERMITIDO = "Lo siento, esa solicitud no se puede realizar";

// Caché del catálogo: evita consultar Supabase en cada mensaje
let catalogoCache = { texto: null, vence: 0, cantidad: 0 };
const CACHE_MS = 60 * 1000;

const obtenerCatalogo = async () => {
  const ahora = Date.now();
  if (catalogoCache.texto && ahora < catalogoCache.vence) {
    return { texto: catalogoCache.texto, cantidad: catalogoCache.cantidad };
  }

  const { data: productos, error } = await supabase
    .from("productos")
    .select("nombre, presentacion, precio_detal, activo, categorias ( nombre )")
    .eq("activo", true);

  if (error) throw new Error(`Supabase productos: ${error.message}`);

  if (!productos || productos.length === 0) {
    catalogoCache = { texto: "", vence: ahora + CACHE_MS, cantidad: 0 };
    return { texto: "", cantidad: 0 };
  }

  // Formato compacto: menos tokens = menos riesgo de límites de Groq
  const texto = productos
    .map((p) => {
      const cat = p.categorias?.nombre ? ` [${p.categorias.nombre}]` : "";
      const pres = p.presentacion ? ` (${p.presentacion})` : "";
      return `- ${p.nombre}${pres}${cat}: $${Number(p.precio_detal).toLocaleString("es-CO")}`;
    })
    .join("\n");

  catalogoCache = { texto, vence: ahora + CACHE_MS, cantidad: productos.length };
  return { texto, cantidad: productos.length };
};

// ==========================
// CHAT
// ==========================

export const chatearConDistribuidoraAnita = async (req, res) => {
  const { mensaje, sesionId, usuarioId } = req.body || {};

  try {
    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `Distribuidora_sesion_${Date.now()}`;

    // 1. Catálogo (con caché)
    const { texto: catalogoTexto, cantidad } = await obtenerCatalogo();

    if (cantidad === 0) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos bebidas registradas en la carta.",
        sesionId: idSesionValido,
      });
    }

    // 2. Últimos mensajes de la sesión (6 es suficiente y ahorra tokens)
    const { data: previos } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje")
      .eq("sesion_id", idSesionValido)
      .order("created_at", { ascending: false })
      .limit(6);

    const historial = (previos || [])
      .reverse()
      .filter((m) => !m.mensaje.startsWith(MSG_NO_PERMITIDO))
      .map((m) => ({
        role: m.emisor === "user" ? "user" : "assistant",
        content: m.mensaje,
      }));

    const esPrimerMensaje = !previos || previos.length === 0;

    // 3. Regla de saludo
    const reglaSaludo = esPrimerMensaje
      ? `Esta es la PRIMERA interacción. Si el cliente solo saluda, responde: "¡Hola! Bienvenido a Distribuidora Anita 🥤. ¿En qué antojo refrescante te podemos colaborar hoy?". Si en cambio pregunta algo directo, responde la pregunta sin saludar.`
      : `La conversación YA INICIÓ. NO saludes, NO digas "Hola" ni "Bienvenido" y NO te presentes de nuevo. Responde directo a lo que pregunta el cliente.`;

    // 4. Prompt del sistema
    const systemPrompt = `
Eres el asesor virtual de la Distribuidora "Distribuidora Anita".
Eres alegre, amable, refrescante y educado.

CATÁLOGO ACTUAL EN TIENDA (nombre, presentación, [categoría]: precio):
${catalogoTexto}

ALCANCE:
- Solo puedes hablar de Distribuidora Anita: productos, precios y categorías según el catálogo de arriba.
- No inventes productos ni precios que no estén en el catálogo.

SI ESTÁ PERMITIDO:
- Preguntas sobre productos, categorías (cervezas, licores, gaseosas, jugos, etc.), precios o presentaciones del catálogo.
- Mensajes con errores de ortografía: interpreta la intención y responde amablemente.

NO ESTÁ PERMITIDO:
- Temas ajenos a la distribuidora (matemáticas, programación, noticias, etc.).
- En esos casos responde únicamente:
  "${MSG_NO_PERMITIDO} por este medio. Solo puedo ayudarte con los productos y precios de Distribuidora Anita 🥤. ¿Te muestro nuestro catálogo?"

REGLAS DE ATENCIÓN:
1. ${reglaSaludo}
2. Precios siempre en pesos colombianos ($ COP).
3. Texto plano sin tablas, sin asteriscos ni markdown.
`;

    // 5. Inferencia con modelos de respaldo
    let respuestaTexto = null;
    const errores = [];

    for (const modelo of MODELOS) {
      try {
        const completion = await getGroq().chat.completions.create({
          model: modelo,
          messages: [
            { role: "system", content: systemPrompt },
            ...historial,
            { role: "user", content: mensaje.trim() },
          ],
          temperature: 0.1,
          max_tokens: 500,
        });

        respuestaTexto = completion.choices[0]?.message?.content?.trim();
        if (respuestaTexto) {
          console.log(`[chat] OK con el modelo: ${modelo}`);
          break;
        }
      } catch (errModelo) {
        // status 401 = clave inválida | 404 = modelo retirado | 413/429 = límite de uso
        const detalle = `${modelo} -> status ${errModelo.status ?? "?"}: ${errModelo.message}`;
        errores.push(detalle);
        console.warn(`[chat] Falló ${detalle}`);
      }
    }

    // Si ningún modelo respondió: NO guardamos nada y devolvemos 503
    // para que la app reintente y no se ensucie el historial.
    if (!respuestaTexto) {
      console.error("[chat] Todos los modelos fallaron:", errores.join(" | "));
      return res.status(503).json({
        respuesta:
          "En este momento tenemos una alta demanda en el chat. Por favor intenta de nuevo en unos segundos.",
        sesionId: idSesionValido,
      });
    }

    // 6. Guardar pregunta y respuesta
    const { error: errorInsert } = await supabase.from("mensajes_chat").insert([
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
    ]);

    if (errorInsert) {
      console.error("[chat] Error guardando historial:", errorInsert.message);
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido,
    });
  } catch (error) {
    console.error("[chat] Error general:", error);
    return res.status(503).json({
      respuesta:
        "Ocurrió un inconveniente temporal con el chat. Intenta nuevamente en un momento.",
      sesionId: sesionId || `Distribuidora_sesion_${Date.now()}`,
    });
  }
};

// ==========================
// HISTORIAL
// ==========================

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