import { Router } from "express";
import {registro, login, obtenerPerfil, actualizarPerfil, cambiarPassword} from "../controllers/auth-controller.js";
import { verificarToken } from "../middlewares/auth-middleware.js";
import { autenticarConGoogle } from "../controllers/googleauth-controller.js";

const router = Router();


// Públicas

router.post("/register", registro);

router.post("/login", login);


// Privadas

router.get(
    "/profile",
    verificarToken,
    obtenerPerfil
);

router.put(
    "/profile",
    verificarToken,
    actualizarPerfil
);

router.put(
    "/change-password",
    verificarToken,
    cambiarPassword
);

//Endpoint: POST/api/auth/google
router.post("/google", autenticarConGoogle);

export default router;