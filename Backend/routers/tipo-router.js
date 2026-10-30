import express from 'express';
import * as TipoController from '../controllers/tipo-controller.js';

const router = express.Router();

router.get('/', TipoController.listarTipos);

export default router;