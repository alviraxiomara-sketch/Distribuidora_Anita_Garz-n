import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class ProductoTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? tipo;
  final int maxLines;

  const ProductoTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.tipo,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class ProductoImagenPicker extends StatelessWidget {
  final img_picker.XFile? imagenSeleccionada;
  final VoidCallback onTap;

  const ProductoImagenPicker({
    super.key,
    required this.imagenSeleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: imagenSeleccionada != null
                  ? (kIsWeb
                      ? Image.network(imagenSeleccionada!.path, fit: BoxFit.cover)
                      : Image.file(File(imagenSeleccionada!.path), fit: BoxFit.cover))
                  : const Icon(
                      Icons.camera_alt_rounded,
                      size: 42,
                      color: Color(0xFF031A2E),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Anexar Imagen',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Georgia',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductoFormContainer extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController valorController;
  final TextEditingController precioMayoristaController;
  final TextEditingController presentacionController;
  final TextEditingController cantidadController;
  final TextEditingController cantidadMinimaMayoristaController;
  final TextEditingController descripcionController;
  final img_picker.XFile? imagenProducto;
  final VoidCallback onTapImagen;
  final List<dynamic> categoriasList;
  final int? categoriaSeleccionadaId;
  final ValueChanged<int?> onChangedCategoria;
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
    required this.descripcionController,
    required this.imagenProducto,
    required this.onTapImagen,
    required this.categoriasList,
    required this.categoriaSeleccionadaId,
    required this.onChangedCategoria,
    required this.onAgregarCategoriaClick,
    required this.onGuardar,
    required this.cargando,
    required this.cargandoCategorias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3954),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: ProductoImagenPicker(imagenSeleccionada: imagenProducto, onTap: onTapImagen)),
          const SizedBox(height: 20),
          
          const Text('Nombre del Producto', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ProductoTextField(hint: '', controller: nombreController),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio Detal', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    ProductoTextField(hint: '', controller: valorController, tipo: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio Mayorista', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    ProductoTextField(hint: '', controller: precioMayoristaController, tipo: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Presentación', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    ProductoTextField(hint: 'Ej. Botella', controller: presentacionController),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cantidad', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    ProductoTextField(hint: '', controller: cantidadController, tipo: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),

          const Text('Cant. Mínima Mayorista', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ProductoTextField(hint: 'Ej. 100', controller: cantidadMinimaMayoristaController, tipo: TextInputType.number),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categoría', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF031A2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onAgregarCategoriaClick,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF00A8FF), size: 24),
                  tooltip: 'Agregar nueva categoría',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          cargandoCategorias
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Color(0xFF00A8FF)),
                )
              : Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: categoriaSeleccionadaId,
                      hint: const Text('Selecciona una categoría', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      isExpanded: true,
                      dropdownColor: const Color(0xFFD9D9D9),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                      items: categoriasList.map<DropdownMenuItem<int>>((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'] ?? cat['id_categoria'],
                          child: Text(cat['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.black, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: onChangedCategoria,
                    ),
                  ),
                ),

          const Text('Descripción del producto', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ProductoTextField(hint: '', controller: descripcionController, maxLines: 2),
          const SizedBox(height: 16),
          
          Center(
            child: SizedBox(
              width: 150,
              height: 42,
              child: cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                  : ElevatedButton(
                      onPressed: onGuardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0073B7),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: const Text('Agregar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}