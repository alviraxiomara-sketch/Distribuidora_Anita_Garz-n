// Backend/controllers/configuracion-controller.js
// AJUSTA la ruta/export de supabase según tu archivo config/supabase.js
import supabase from '../config/supabase.js';

const TELEFONO_DEFECTO = '322 732 8596';
const DIRECCION_DEFECTO = 'Calle 4 A Sur #16-05';

// GET /api/configuracion  (público)
export const obtenerConfiguracion = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('configuracion')
      .select('telefono, direccion')
      .eq('id', 1)
      .maybeSingle();

    if (error) throw error;

    return res.status(200).json({
      telefono: data?.telefono ?? TELEFONO_DEFECTO,
      direccion: data?.direccion ?? DIRECCION_DEFECTO,
    });
  } catch (error) {
    console.error('Error al obtener configuración:', error);
    return res.status(500).json({ message: 'Error al obtener la configuración' });
  }
};

// PUT /api/configuracion  (solo administrador)
export const actualizarConfiguracion = async (req, res) => {
  try {
    const { telefono, direccion } = req.body;

    if (!telefono || !direccion) {
      return res
        .status(400)
        .json({ message: 'Teléfono y dirección son obligatorios' });
    }

    const { error } = await supabase
      .from('configuracion')
      .upsert({
        id: 1,
        telefono: String(telefono).trim(),
        direccion: String(direccion).trim(),
        updated_at: new Date().toISOString(),
      });

    if (error) throw error;

    return res.status(200).json({
      message: 'Configuración actualizada',
      telefono: String(telefono).trim(),
      direccion: String(direccion).trim(),
    });
  } catch (error) {
    console.error('Error al actualizar configuración:', error);
    return res.status(500).json({ message: 'Error al actualizar la configuración' });
  }
};