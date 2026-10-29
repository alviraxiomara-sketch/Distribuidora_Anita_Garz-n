const TipoModel = require('../models/tipo-model');

class TipoController {
  static async listarTipos(req, res) {
    try {
      const tipos = await TipoModel.obtenerTodos();
      res.json(tipos);
    } catch (error) {
      res.status(500).json({ error: 'Error al obtener los tipos de productos' });
    }
  }
}

module.exports = TipoController;