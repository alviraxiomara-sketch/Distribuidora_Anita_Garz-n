import { Router } from 'express';
import {
  obtenerConfiguracion,
  actualizarConfiguracion,
} from '../controllers/configuracion-controller.js';
import * as authMw from '../middlewares/auth-middleware.js';
import { verificarRol } from '../middlewares/rol-middleware.js';

// Busca el middleware de autenticación con los nombres más comunes
const verificarToken =
  authMw.default ??
  authMw.verificarToken ??
  authMw.verifyToken ??
  authMw.authMiddleware ??
  authMw.autenticar ??
  authMw.auth ??
  authMw.protegerRuta;

// Si no lo encuentra, la ruta protegida falla con un mensaje claro
// pero el servidor NO se cae.
const autenticacion =
  typeof verificarToken === 'function'
    ? verificarToken
    : (req, res) =>
        res.status(500).json({
          error: 'No se encontró el middleware de autenticación',
        });

const router = Router();

router.get('/', obtenerConfiguracion);
router.put(
  '/',
  autenticacion,
  verificarRol('admin', 'administrador'),
  actualizarConfiguracion
);

export default router;