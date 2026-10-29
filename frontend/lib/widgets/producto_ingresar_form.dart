import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class ProductoFormContainer extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController valorController;
  final TextEditingController precioMayoristaController;
  final TextEditingController presentacionController;
  final TextEditingController cantidadController;
  final TextEditingController cantidadMinimaMayoristaController;
  
  final img_picker.XFile? imagenProducto;
  final VoidCallback onTapImagen;
  
  final List<dynamic> categoriasList;
  final int? categoriaSeleccionadaId;
  final ValueChanged<int?> onChangedCategoria;
  
  final List<dynamic> tiposList;
  final int? tipoSeleccionadoId;
  final ValueChanged<int?> onChangedTipo;
  final bool cargandoTipos;
  
  final VoidCallback onAgregarCategoriaClick;
  final VoidCallback onGuardar;
  final bool cargando;
  final bool cargandoCategorias;

  const ProductoFormContainer({
    super.key,
    required this.nombreController,
    required this.valorController,
    required this.precioMayoristaController,
    required this.presentacionController,
    required this.cantidadController,
    required this.cantidadMinimaMayoristaController,
    required this.imagenProducto,
    required this.onTapImagen,
    required this.categoriasList,
    required this.categoriaSeleccionadaId,
    required this.onChangedCategoria,
    required this.tiposList,
    required this.tipoSeleccionadoId,
    required this.onChangedTipo,
    required this.cargandoTipos,
    required this.onAgregarCategoriaClick,
    required this.onGuardar,
    required this.cargando,
    required this.cargandoCategorias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ingresar Producto', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          
          _buildTextField('Nombre del producto', nombreController),
          _buildTextField('Precio detal', valorController, keyboardType: TextInputType.number),
          _buildTextField('Precio mayorista', precioMayoristaController, keyboardType: TextInputType.number),
          _buildTextField('Presentación (ej. Botella 1L)', presentacionController),
          _buildTextField('Cantidad en stock', cantidadController, keyboardType: TextInputType.number),
          _buildTextField('Cantidad mínima mayorista', cantidadMinimaMayoristaController, keyboardType: TextInputType.number),
          
          const SizedBox(height: 10),
          
          // Selector de Categoría
          Row(
            children: [
              Expanded(
                child: cargandoCategorias
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : DropdownButtonFormField<int>(
                        value: categoriaSeleccionadaId,
                        dropdownColor: const Color(0xFF063B5D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Seleccione categoría'),
                        items: categoriasList.map<DropdownMenuItem<int>>((cat) {
                          final id = int.tryParse(cat['id'].toString()) ?? 0;
                          final nombre = cat['nombre'] ?? 'Sin nombre';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(nombre, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: onChangedCategoria,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAgregarCategoriaClick,
                icon: const Icon(Icons.add_circle, color: Color(0xFF00A8FF), size: 32),
                tooltip: 'Crear nueva categoría',
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Selector de Tipo
          cargandoTipos
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : DropdownButtonFormField<int>(
                  value: tipoSeleccionadoId,
                  dropdownColor: const Color(0xFF063B5D),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Seleccione tipo'),
                  items: tiposList.map<DropdownMenuItem<int>>((tipo) {
                    final id = int.tryParse(tipo['id'].toString()) ?? 0;
                    final nombre = tipo['nombre'] ?? 'Sin nombre';
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: onChangedTipo,
                ),

          const SizedBox(height: 20),

          // Selector de Imagen
          GestureDetector(
            onTap: onTapImagen,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white54),
              ),
              child: imagenProducto == null
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.camera_alt, color: Colors.white70, size: 40),
                      SizedBox(height: 8),
                      Text('Toca para seleccionar imagen', style: TextStyle(color: Colors.white70)),
                    ]))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(imagenProducto!.path, fit: BoxFit.cover)
                          : Image.file(File(imagenProducto!.path), fit: BoxFit.cover),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Botón Guardar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8FF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: cargando ? null : onGuardar,
            child: cargando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Guardar Producto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withAlpha(25),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}