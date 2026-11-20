import { supabase } from "../config/supabase.js";

export const obtener = async () => {
  const { data, error } = await supabase
    .from("configuracion")
    .select("telefono, direccion")
    .eq("id", 1)
    .single();
  if (error) throw error;
  return data;
};

export const actualizar = async (telefono, direccion) => {
  const { data, error } = await supabase
    .from("configuracion")
    .update({ telefono, direccion })
    .eq("id", 1)
    .select("telefono, direccion")
    .single();
  if (error) throw error;
  return data;
}; 