import { Router } from "express";
import {obtener, agregar, actualizar, eliminar} from "../controllers/carrito-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";

const router = Router();


// ==========================
// OBTENER CARRITO
// ==========================

router.get(
    "/",
    verificarToken,
    obtener
);


// ==========================
// AGREGAR PRODUCTO
// ==========================

router.post(
    "/agregar",
    verificarToken,
    agregar
);


// ==========================
// ACTUALIZAR CANTIDAD
// ==========================

router.put(
    "/actualizar/:idDetalle",
    verificarToken,
    actualizar
);


// ==========================
// ELIMINAR PRODUCTO
// ==========================

router.delete(
    "/eliminar/:idDetalle",
    verificarToken,
    eliminar
);


export default router;