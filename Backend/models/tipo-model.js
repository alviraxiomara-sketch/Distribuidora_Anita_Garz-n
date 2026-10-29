const supabase = require('../supabase'); // Asegúrate de que la ruta apunte bien a tu archivo supabase.js

class TipoModel {
  static async obtenerTodos() {
    const { data, error } = await supabase.from('tipos').select('*');
    if (error) throw error;
    return data;
  }
}

module.exports = TipoModel;