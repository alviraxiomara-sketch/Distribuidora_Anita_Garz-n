import { Router } from "express";
import {crear, obtenerPorPedido, listarTodos, cambiarEstado} from "../controllers/pago-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";

const router = Router();


// ==========================
// REGISTRAR PAGO
// ==========================

router.post(
    "/",
    verificarToken,
    crear
);


// ==========================
// OBTENER PAGO POR PEDIDO
// ==========================

router.get(
    "/pedido/:idPedido",
    verificarToken,
    obtenerPorPedido
);


// ==========================
// TODOS LOS PAGOS
// SOLO ADMIN
// ==========================

router.get(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    listarTodos
);


// ==========================
// CAMBIAR ESTADO DEL PAGO
// SOLO ADMIN
// ==========================

router.put(
    "/:idPago",
    verificarToken,
    verificarRol("ADMIN"),
    cambiarEstado
);


export default router;