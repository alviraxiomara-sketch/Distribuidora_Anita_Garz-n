import express from "express";
import { supabase } from "../config/supabase.js";
import {
  chatearConDistribuidoraAnita,
  obtenerHistorialDistribuidora,
  eliminarHistorialDistribuidora,
} from "../controllers/chatbox-controllers.js";

const router = express.Router();

// Ruta de salud: sirve para despertar Render y mantener activo Supabase.
// URL final: https://distribuidora-anita.onrender.com/api/chatbox/salud
router.get("/salud", async (req, res) => {
  try {
    const { error } = await supabase.from("productos").select("id_producto").limit(1);
    return res.status(error ? 503 : 200).json({
      ok: !error,
      db: !error,
      hora: new Date().toISOString(),
    });
  } catch (e) {
    return res.status(503).json({ ok: false, db: false });
  }
});

router.post("/", chatearConDistribuidoraAnita);
router.get("/historial/:sesionId", obtenerHistorialDistribuidora);
router.delete("/historial/:sesionId", eliminarHistorialDistribuidora);

export default router;