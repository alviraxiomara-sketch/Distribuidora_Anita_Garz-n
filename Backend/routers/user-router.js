import { Router } from "express";
import {listarUsuarios, obtenerUsuario, cambiarRol, activarUsuario, desactivarUsuario} from "../controllers/user-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { verificarRol } from "../middlewares/rol-middleware.js";

const router = Router();

// Solo ADMIN

router.get(
    "/",
    verificarToken,
    verificarRol("ADMIN"),
    listarUsuarios
);

router.get(
    "/:id",
    verificarToken,
    verificarRol("ADMIN"),
    obtenerUsuario
);

router.put(
    "/:id/rol",
    verificarToken,
    verificarRol("ADMIN"),
    cambiarRol
);

router.put(
    "/:id/activar",
    verificarToken,
    verificarRol("ADMIN"),
    activarUsuario
);

router.put(
    "/:id/desactivar",
    verificarToken,
    verificarRol("ADMIN"),
    desactivarUsuario
);

export default router;