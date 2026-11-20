import { Router } from 'express';
import {
  obtenerConfiguracion,
  actualizarConfiguracion,
} from '../controllers/configuracion-controller.js';
import * as authMw from '../middlewares/auth-middleware.js';
import * as rolMw from '../middlewares/rol-middleware.js';

// Busca los middlewares aunque tengan otro nombre de exportación
const verificarToken =
  authMw.default ?? authMw.verificarToken ?? authMw.authMiddleware ??
  authMw.verifyToken ?? authMw.autenticar ?? authMw.auth;

const soloAdmin =
  rolMw.default ?? rolMw.soloAdmin ?? rolMw.esAdmin ??
  rolMw.isAdmin ?? rolMw.verificarAdmin ?? rolMw.rolMiddleware;

if (typeof verificarToken !== 'function' || typeof soloAdmin !== 'function') {
  throw new Error(
    'Revisa los nombres exportados en auth-middleware.js y rol-middleware.js'
  );
}

const router = Router();

router.get('/', obtenerConfiguracion);
router.put('/', verificarToken, soloAdmin, actualizarConfiguracion);

export default router;