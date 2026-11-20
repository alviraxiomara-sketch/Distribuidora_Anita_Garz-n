import { Router } from "express";
import { obtener, actualizar } from "../controllers/configuracion-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js"; // AJUSTA
import { soloAdmin } from "../middlewares/rol-middleware.js";       // AJUSTA

const router = Router();

router.get("/", obtener);                                // todos los clientes
router.put("/", verificarToken, soloAdmin, actualizar);  // solo administrador

export default router;