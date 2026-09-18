import { Router } from "express";
import {listarMisNotificaciones, marcarComoLeida, eliminar} from "../controllers/notificacion-controller.js";
import {verificarToken} from "../middlewares/auth-middleware.js";

const router = Router();


// ==========================
// MIS NOTIFICACIONES
// ==========================

router.get(
    "/",
    verificarToken,
    listarMisNotificaciones
);


// ==========================
// MARCAR LEÍDA
// ==========================

router.put(
    "/:id/leida",
    verificarToken,
    marcarComoLeida
);

// ==========================
// ELIMINAR NOTIFICACIÓN
// ==========================

router.delete(
    "/:id/eliminar",
    verificarToken,
    eliminar
);
export default router;