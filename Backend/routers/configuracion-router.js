import { Router } from 'express';
import {
  obtenerConfiguracion,
  actualizarConfiguracion,
} from '../controllers/configuracion-controller.js';
import { verificarToken } from '../middlewares/auth-middleware.js';
import { verificarRol } from '../middlewares/rol-middleware.js';

const router = Router();

router.get('/', obtenerConfiguracion);
router.put(
  '/',
  verificarToken,
  verificarRol('admin', 'administrador'),
  actualizarConfiguracion
);

export default router;