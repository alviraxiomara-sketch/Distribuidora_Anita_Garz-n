import { Router } from "express";
import {crear, listarMisPedidos, listarTodos, obtenerPedido, cambiarEstado} from "../controllers/pedido-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";

const router = Router();


// ==========================
// CREAR PEDIDO
// ==========================

router.post(
    "/",
    verificarToken,
    crear
);


// ==========================
// MIS PEDIDOS
// ==========================

router.get(
    "/mis-pedidos",
    verificarToken,
    listarMisPedidos
);


// ==========================
// TODOS LOS PEDIDOS
// SOLO ADMIN
// ==========================

router.get(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    listarTodos
);


// ==========================
// PEDIDO POR ID
// ==========================

router.get(
    "/:id",
    verificarToken,
    obtenerPedido
);


// ==========================
// CAMBIAR ESTADO
// SOLO ADMIN
// ==========================

router.put(
    "/:id/estado",
    verificarToken,
    verificarRol("ADMIN"),
    cambiarEstado
);


export default router;