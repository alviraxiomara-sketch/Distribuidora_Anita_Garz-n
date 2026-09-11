import { Router } from "express";
import {forgotPassword, resetPassword} from "../controllers/recuperar-controller.js";

const router = Router();


// ==========================
// SOLICITAR CÓDIGO
// ==========================

router.post(

    "/forgot-password",

    forgotPassword

);


// ==========================
// CAMBIAR CONTRASEÑA
// ==========================

router.post(

    "/reset-password",

    resetPassword

);


export default router;