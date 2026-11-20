// Backend/routers/configuracion-router.js
import { Router } from 'express';
import {
  obtenerConfiguracion,
  actualizarConfiguracion,
} from '../controllers/configuracion-controller.js';

// AJUSTA estos imports y nombres a los que exportan tus middlewares:
// Backend/middlewares/auth-middleware.js  y  Backend/middlewares/rol-middleware.js
// Copia exactamente cómo los usa otro router tuyo (por ejemplo tipo-router.js).
import { verificarToken } from '../middlewares/auth-middleware.js';
import { soloAdmin } from '../middlewares/rol-middleware.js';

const router = Router();

router.get('/', obtenerConfiguracion);
router.put('/', verificarToken, soloAdmin, actualizarConfiguracion);

export default router;