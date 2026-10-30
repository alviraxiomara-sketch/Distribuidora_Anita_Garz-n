import { supabase } from '../config/supabase.js';

export class TipoModel {
  static async obtenerTodos() {
    const { data, error } = await supabase.from('tipos').select('*');
    if (error) throw error;
    return data;
  }
}