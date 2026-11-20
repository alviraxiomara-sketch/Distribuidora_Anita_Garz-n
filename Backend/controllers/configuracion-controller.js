import * as model from "../models/configuracion-model.js";

export const obtener = async (req, res) => {
  try {
    res.json(await model.obtener());
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Error al leer la configuración" });
  }
};

export const actualizar = async (req, res) => {
  const { telefono, direccion } = req.body;
  if (!telefono || !direccion) {
    return res.status(400).json({ error: "Faltan datos" });
  }
  try {
    res.json(await model.actualizar(telefono.trim(), direccion.trim()));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Error al guardar" });
  }
};