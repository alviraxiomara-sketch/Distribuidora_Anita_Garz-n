import { Router } from "express";
import {
    listarMisNotificaciones,
    marcarComoLeida,
    marcarTodasComoLeidas,
    guardarEstado,
    eliminar
} from "../controllers/notificacion-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";

const router = Router();

// ==========================
// MIS NOTIFICACIONES
// ==========================
router.get("/", verificarToken, listarMisNotificaciones);

// ==========================
// MARCAR TODAS LEÍDAS
// ==========================
router.put("/marcar-todas-leidas", verificarToken, marcarTodasComoLeidas);

// ==========================
// MARCAR UNA LEÍDA
// ==========================
router.put("/:id/leida", verificarToken, marcarComoLeida);

// ==========================
// ELIMINAR NOTIFICACIÓN
// ==========================
router.delete("/:id/eliminar", verificarToken, eliminar);

// ==========================
// GUARDAR ESTADO DE ACCIÓN
// ==========================
router.put("/:id/estado-accion", verificarToken, guardarEstado);

export default router;