import { Router } from "express";
import {listarInventario, obtenerInventarioProducto, crear, entrada, salida, ajuste, actualizarMinimo, listarMovimientos, listarMovimientosProducto} from "../controllers/inventario-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";

const router = Router();


// ==========================
// CONSULTAR INVENTARIO
// ==========================

// Todo el inventario

router.get(
    "/",
    verificarToken,
    listarInventario
);


// Inventario de un producto

router.get(
    "/producto/:idProducto",
    verificarToken,
    obtenerInventarioProducto
);


// ==========================
// MOVIMIENTOS
// ==========================

// Todos los movimientos

router.get(
    "/movimientos",
    verificarToken,
    verificarRol("ADMIN"),
    listarMovimientos
);


// Movimientos de un producto

router.get(
    "/movimientos/producto/:idProducto",
    verificarToken,
    verificarRol("ADMIN"),
    listarMovimientosProducto
);


// ==========================
// SOLO ADMIN
// ==========================

// Crear inventario

router.post(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    crear
);


// Entrada de inventario

router.post(
    "/entrada/:idProducto",
    verificarToken,
    verificarRol("ADMIN"),
    entrada
);


// Salida de inventario

router.post(
    "/salida/:idProducto",
    verificarToken,
    verificarRol("ADMIN"),
    salida
);


// Ajuste de inventario

router.post(
    "/ajuste/:idProducto",
    verificarToken,
    verificarRol("ADMIN"),
    ajuste
);


// Actualizar stock mínimo

router.put(
    "/minimo/:idProducto",
    verificarToken,
    verificarRol("ADMIN"),
    actualizarMinimo
);


export default router;