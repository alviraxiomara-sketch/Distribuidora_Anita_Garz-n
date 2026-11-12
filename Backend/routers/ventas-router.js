import { Router } from "express";
import { resumenVentas } from "../controllers/ventas-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";

const router = Router();

// ==========================
// RESUMEN DE VENTAS (SOLO ADMIN)
// ==========================
router.get("/resumen", verificarToken, verificarRol("ADMIN"), resumenVentas);

export default router;