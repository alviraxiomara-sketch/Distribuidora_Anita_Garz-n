import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class ProductoFormContainer extends StatefulWidget {
  final TextEditingController nombreController;
  final TextEditingController valorController;
  final TextEditingController precioMayoristaController;
  final TextEditingController presentacionController;
  final TextEditingController cantidadController;
  final TextEditingController cantidadMinimaMayoristaController;
  
  // Nuevo parámetro opcional para recibir o reportar el color de tapa seleccionado
  final String? tapaSeleccionada;
  final ValueChanged<String?>? onChangedTapa;

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
    this.tapaSeleccionada,
    this.onChangedTapa,
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
  State<ProductoFormContainer> createState() => _ProductoFormContainerState();
}

class _ProductoFormContainerState extends State<ProductoFormContainer> {
  // Opciones de presentación actualizadas (Garrafa, Media, Botella, Lata, Caja)
  List<String> _obtenerOpcionesPresentacion(String nombre) {
    final texto = nombre.toLowerCase();

    if (texto.contains('cerveza') || texto.contains('aguila') || texto.contains('corona') || texto.contains('heineken') || texto.contains('pilsen') || texto.contains('poker') || texto.contains('club')) {
      return ['Botella', 'Lata', 'Caja'];
    } else if (texto.contains('aguardiente') || texto.contains('ron') || texto.contains('whisky') || texto.contains('tequila') || texto.contains('licor')) {
      return ['Media', 'Botella', 'Garrafa', 'Caja'];
    } else if (texto.contains('gaseosa') || texto.contains('coca') || texto.contains('postobon') || texto.contains('colombiana') || texto.contains('sprite')) {
      return ['Botella', 'Lata', 'Caja'];
    } else if (texto.contains('jugo') || texto.contains('hit') || texto.contains('nectar')) {
      return ['Caja', 'Botella', 'Lata'];
    }

    return ['Garrafa', 'Media', 'Botella', 'Lata', 'Caja'];
  }

  // Verifica si la presentación elegida requiere color de tapa
  bool _requiereTapa(String presentacion) {
    return ['Media', 'Botella', 'Garrafa'].contains(presentacion);
  }

  @override
  Widget build(BuildContext context) {
    final nombreTexto = widget.nombreController.text;
    final opcionesPresentacion = _obtenerOpcionesPresentacion(nombreTexto);
    final muestraTapa = _requiereTapa(widget.presentacionController.text);

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
          
          _buildTextField(
            'Nombre del producto', 
            widget.nombreController,
            onChanged: (val) {
              setState(() {
                widget.presentacionController.clear();
                if (widget.onChangedTapa != null) {
                  widget.onChangedTapa!(null);
                }
              });
            },
          ),
          _buildTextField('Precio detal', widget.valorController, keyboardType: TextInputType.number),
          _buildTextField('Precio mayorista', widget.precioMayoristaController, keyboardType: TextInputType.number),
          
          // Desplegable de Presentación limpio
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              value: opcionesPresentacion.contains(widget.presentacionController.text)
                  ? widget.presentacionController.text
                  : null,
              dropdownColor: const Color(0xFF063B5D),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Presentación'),
              hint: const Text('Seleccione presentación', style: TextStyle(color: Colors.white70)),
              items: opcionesPresentacion.map<DropdownMenuItem<String>>((p) {
                return DropdownMenuItem<String>(
                  value: p,
                  child: Text(p, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  widget.presentacionController.text = val ?? '';
                  if (!_requiereTapa(val ?? '') && widget.onChangedTapa != null) {
                    widget.onChangedTapa!(null);
                  }
                });
              },
            ),
          ),

          // Menú desplegable independiente de Tapa (con Tapa Amarilla en lugar de Blanca)
          if (muestraTapa)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: widget.tapaSeleccionada,
                dropdownColor: const Color(0xFF063B5D),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Color de Tapa'),
                hint: const Text('Seleccione tapa', style: TextStyle(color: Colors.white70)),
                items: ['Azul', 'Verde', 'Negra', 'Roja', 'Amarilla'].map<DropdownMenuItem<String>>((tapa) {
                  return DropdownMenuItem<String>(
                    value: tapa,
                    child: Text('Tapa $tapa', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: widget.onChangedTapa,
              ),
            ),

          _buildTextField('Cantidad en stock', widget.cantidadController, keyboardType: TextInputType.number),
          _buildTextField('Cantidad mínima mayorista', widget.cantidadMinimaMayoristaController, keyboardType: TextInputType.number),
          
          const SizedBox(height: 10),
          
          // Selector de Categoría
          Row(
            children: [
              Expanded(
                child: widget.cargandoCategorias
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : DropdownButtonFormField<int>(
                        value: widget.categoriasList.any((cat) => (int.tryParse((cat['id_categoria'] ?? cat['id'])?.toString() ?? '0') ?? 0) == widget.categoriaSeleccionadaId)
                            ? widget.categoriaSeleccionadaId
                            : null,
                        dropdownColor: const Color(0xFF063B5D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Seleccione categoría'),
                        items: widget.categoriasList.map<DropdownMenuItem<int>>((cat) {
                          final id = int.tryParse((cat['id_categoria'] ?? cat['id'])?.toString() ?? '0') ?? 0;
                          final nombre = cat['Nombre'] ?? cat['nombre'] ?? 'Sin nombre';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(nombre, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: widget.onChangedCategoria,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onAgregarCategoriaClick,
                icon: const Icon(Icons.add_circle, color: Color(0xFF00A8FF), size: 32),
                tooltip: 'Crear nueva categoría',
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Selector de Tipo
          widget.cargandoTipos
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : DropdownButtonFormField<int>(
                  value: widget.tiposList.any((tipo) => (int.tryParse((tipo['id_tipo'] ?? tipo['id'])?.toString() ?? '0') ?? 0) == widget.tipoSeleccionadoId)
                      ? widget.tipoSeleccionadoId
                      : null,
                  dropdownColor: const Color(0xFF063B5D),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Seleccione tipo'),
                  items: widget.tiposList.map<DropdownMenuItem<int>>((tipo) {
                    final id = int.tryParse((tipo['id_tipo'] ?? tipo['id'])?.toString() ?? '0') ?? 0;
                    final nombre = tipo['nombre'] ?? 'Sin nombre';
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: widget.onChangedTipo,
                ),

          const SizedBox(height: 20),

          // Selector de Imagen
          GestureDetector(
            onTap: widget.onTapImagen,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white54),
              ),
              child: widget.imagenProducto == null
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.camera_alt, color: Colors.white70, size: 40),
                      SizedBox(height: 8),
                      Text('Toca para seleccionar imagen', style: TextStyle(color: Colors.white70)),
                    ]))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(widget.imagenProducto!.path, fit: BoxFit.cover)
                          : Image.file(File(widget.imagenProducto!.path), fit: BoxFit.cover),
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
            onPressed: widget.cargando ? null : widget.onGuardar,
            child: widget.cargando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Guardar Producto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, ValueChanged<String>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
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