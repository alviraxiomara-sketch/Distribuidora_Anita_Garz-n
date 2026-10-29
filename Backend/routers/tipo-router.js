const express = require('express');
const router = express.Router();
const TipoController = require('../controllers/tipo-controller');

router.get('/', TipoController.listarTipos);

module.exports = router;