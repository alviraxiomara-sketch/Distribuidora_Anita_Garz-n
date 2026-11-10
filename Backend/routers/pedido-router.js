import { Router } from "express";
import {
    crear,
    listarMisPedidos,
    listarTodos,
    obtenerPedido,
    cambiarEstado,
    cambiarEstadoYNotificar // <--- 1. Importamos la nueva función
} from "../controllers/pedido-controller.js";
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
// TODOS LOS PEDIDOS (SOLO ADMIN)
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
// CAMBIAR ESTADO GENERAL (SOLO ADMIN)
// ==========================
router.put(
    "/:id/estado",
    verificarToken,
    verificarRol("ADMIN"),
    cambiarEstado
);

// ==========================
// CAMBIAR ESTADO Y NOTIFICAR AL CLIENTE (SOLO ADMIN)
// ==========================
router.put(
    "/:id/estado-notificar",
    verificarToken,
    verificarRol("ADMIN"),
    cambiarEstadoYNotificar
);

export default router;