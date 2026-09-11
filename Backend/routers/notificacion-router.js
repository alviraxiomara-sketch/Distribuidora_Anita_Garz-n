import { Router } from "express";
import {listarMisNotificaciones, marcarComoLeida} from "../controllers/notificacion-controller.js";
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

export default router;