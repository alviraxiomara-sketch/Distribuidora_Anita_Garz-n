import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class EditarProductoDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<dynamic> categoriasList;
  final Function({
    required int? idProd,
    required int? idCat,
    required String nombre,
    required String precio,
    required String presentacion,
    required int stock,
    img_picker.XFile? imagen,
  }) onGuardar;

  const EditarProductoDialog({
    super.key,
    required this.item,
    required this.categoriasList,
    required this.onGuardar,
  });

  @override
  State<EditarProductoDialog> createState() => _EditarProductoDialogState();
}

class _EditarProductoDialogState extends State<EditarProductoDialog> {
  late final TextEditingController _nombreC;
  late final TextEditingController _precioC;
  late final TextEditingController _presC;
  late final TextEditingController _stockC;

  int? _categoriaId;
  img_picker.XFile? _nuevaImagen;

  @override
  void initState() {
    super.initState();
    final p = widget.item['productos'] ?? widget.item;
    _nombreC = TextEditingController(text: '${p['nombre'] ?? widget.item['nombre'] ?? ''}');
    _precioC = TextEditingController(text: '${p['precio_detal'] ?? p['precio'] ?? '0'}');
    _presC = TextEditingController(text: '${p['presentacion'] ?? 'Unidad'}');
    _stockC = TextEditingController(text: '${widget.item['stock_actual'] ?? widget.item['cantidad'] ?? 0}');
    
    _categoriaId = p['id_categoria'] ?? (widget.categoriasList.isNotEmpty ? widget.categoriasList[0]['id_categoria'] : null);
  }

  @override
  void dispose() {
    _nombreC.dispose();
    _precioC.dispose();
    _presC.dispose();
    _stockC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.item['productos'] ?? widget.item;

    return AlertDialog(
      backgroundColor: const Color(0xFF063B5D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.edit, color: Color(0xFF00A8FF)),
        SizedBox(width: 8),
        Text('Editar Producto', style: TextStyle(color: Colors.white, fontSize: 18)),
      ]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picker = img_picker.ImagePicker();
                final img = await picker.pickImage(source: img_picker.ImageSource.gallery, maxWidth: 600, imageQuality: 50);
                if (img != null) setState(() => _nuevaImagen = img);
              },
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00A8FF)),
                ),
                child: _nuevaImagen != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_nuevaImagen!.path, fit: BoxFit.cover))
                    : (p['imagen_url'] != null && p['imagen_url'].toString().isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(p['imagen_url'], fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.camera_alt, color: Colors.white70)))
                        : const Icon(Icons.camera_alt, color: Colors.white70, size: 32)),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Toca para cambiar imagen', style: TextStyle(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _categoriaId,
              dropdownColor: const Color(0xFF031A2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: const TextStyle(color: Color(0xFF00A8FF)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF00A8FF).withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00A8FF)), borderRadius: BorderRadius.circular(10)),
              ),
              items: widget.categoriasList.map<DropdownMenuItem<int>>((cat) {
                return DropdownMenuItem<int>(
                  value: cat['id_categoria'] is int ? cat['id_categoria'] : int.tryParse(cat['id_categoria'].toString()) ?? 0,
                  child: Text(cat['nombre'] ?? 'Sin nombre'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _categoriaId = val),
            ),
            const SizedBox(height: 12),
            _input('Nombre', _nombreC),
            const SizedBox(height: 10),
            _input('Precio Detal', _precioC, TextInputType.number),
            const SizedBox(height: 10),
            _input('Presentación', _presC),
            const SizedBox(height: 10),
            _input('Stock Actual', _stockC, TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A8FF)),
          onPressed: () {
            Navigator.pop(context);
            widget.onGuardar(
              idProd: p['id_producto'] ?? widget.item['id_producto'],
              idCat: _categoriaId,
              nombre: _nombreC.text,
              precio: _precioC.text,
              presentacion: _presC.text,
              stock: int.tryParse(_stockC.text) ?? 0,
              imagen: _nuevaImagen,
            );
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController controller, [TextInputType type = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00A8FF)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF00A8FF).withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00A8FF)), borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}