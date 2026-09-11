import { Router } from "express";
import {crear, listarProductos, obtener, listarPorCategoria, buscar, actualizar, desactivar} from "../controllers/producto-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";
import { upload } from "../config/cloudinary.js";

const router = Router();

// ==========================
// CONSULTAS
// ==========================

// Listar productos

router.get(
    "/",
    verificarToken,
    listarProductos
);


// Buscar producto por nombre

router.get(
    "/buscar",
    verificarToken,
    buscar
);


// Productos por categoría

router.get(
    "/categoria/:idCategoria",
    verificarToken,
    listarPorCategoria
);


// Obtener producto por ID

router.get(
    "/:id",
    verificarToken,
    obtener
);


// ==========================
// SOLO ADMIN
// ==========================

// Crear producto

router.post(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    upload.single("imagen"),
    crear
);


// Actualizar producto

router.put(
    "/:id",
    verificarToken,
    verificarRol("ADMIN"),
    upload.single("imagen"),
    actualizar
);


// Desactivar producto

router.put(
    "/:id/desactivar",
    verificarToken,
    verificarRol("ADMIN"),
    desactivar
);


export default router;