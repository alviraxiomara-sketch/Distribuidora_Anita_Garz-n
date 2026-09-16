import { Router } from "express";
import {crear, listarCategorias, obtener, actualizar, desactivar,activar} from "../controllers/categoria-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";


const router = Router();


// ==========================
// RUTAS PÚBLICAS / USUARIOS AUTENTICADOS
// ==========================

// Obtener todas las categorías

router.get(
    "/",
    verificarToken,
    listarCategorias
);


// Obtener categoría por ID

router.get(
    "/:id",
    verificarToken,
    obtener
);


// ==========================
// RUTAS SOLO ADMIN
// ==========================

// Crear categoría

router.post(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    crear
);


// Actualizar categoría

router.put(
    "/:id",
    verificarToken,
    verificarRol("ADMIN"),
    actualizar
);


// Desactivar categoría

router.put(
    "/:id/desactivar",
    verificarToken,
    verificarRol("ADMIN"),
    desactivar
);

// Activar categoría

router.put(
    "/:id/activar",
    verificarToken,
    verificarRol("ADMIN"),
    activar
);

export default router;