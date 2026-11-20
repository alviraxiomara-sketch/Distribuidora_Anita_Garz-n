import { Router } from 'express';
import {
  obtenerConfiguracion,
  actualizarConfiguracion,
} from '../controllers/configuracion-controller.js';
import { verificarToken } from '../middlewares/auth-middleware.js';
import { verificarRol } from '../middlewares/rol-middleware.js';

const router = Router();

// TEMPORAL: borrar después de ver el log
const verUsuario = (req, res, next) => {
  console.log('USUARIO EN EL TOKEN:', JSON.stringify(req.usuario));
  next();
};

router.get('/', obtenerConfiguracion);
router.put(
  '/',
  verificarToken,
  verUsuario,
  verificarRol('admin', 'administrador'),
  actualizarConfiguracion
);

export default router;