import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_cliente_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/ingresar_producto_widgets.dart';

class IngresarProductoScreen extends StatefulWidget {
  const IngresarProductoScreen({super.key});

  @override
  State<IngresarProductoScreen> createState() => _IngresarProductoScreenState();
}

class _IngresarProductoScreenState extends State<IngresarProductoScreen> {
  final _nombreController = TextEditingController();
  final _valorController = TextEditingController();
  final _precioMayoristaController = TextEditingController();
  final _presentacionController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _cantidadMinimaMayoristaController = TextEditingController();
  final _descripcionController = TextEditingController();

  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  img_picker.XFile? _imagenProducto;

  bool _cargando = false;
  bool _cargandoCategorias = true;
  List<dynamic> _categoriasList = [];
  int? _categoriaSeleccionadaId;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasDesdeBD();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _valorController.dispose();
    _precioMayoristaController.dispose();
    _presentacionController.dispose();
    _cantidadController.dispose();
    _cantidadMinimaMayoristaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategoriasDesdeBD() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${ApiConfig.baseUrl}/categorias');

      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _categoriasList = jsonDecode(response.body);
          _cargandoCategorias = false;
        });
      } else {
        setState(() => _cargandoCategorias = false);
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoCategorias = false);
    }
  }

  void _mostrarModalCrearCategoria() {
    final nuevaCatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF063B5D),
        title: const Text(
          'Nueva Categoría',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: nuevaCatController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8FF),
            ),
            onPressed: () async {
              final nombreCat = nuevaCatController.text.trim();
              if (nombreCat.isEmpty) return;

              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                final url = Uri.parse('${ApiConfig.baseUrl}/categorias');

                final response = await http.post(
                  url,
                  headers: {
                    ...ApiConfig.headers,
                    if (token != null) 'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({'nombre': nombreCat}),
                );

                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.pop(context);
                  await _cargarCategoriasDesdeBD();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Categoría creada con éxito!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final errorData = jsonDecode(response.body);
                  throw Exception(
                    errorData['error'] ?? 'Error al crear categoría',
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarProducto() async {
    if (_nombreController.text.trim().isEmpty ||
        _valorController.text.trim().isEmpty ||
        _categoriaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa los campos obligatorios y selecciona una categoría',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      String? imagenBase64;

      if (_imagenProducto != null) {
        final bytes = await _imagenProducto!.readAsBytes();
        imagenBase64 = base64Encode(bytes);
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/productos');
      final response = await http.post(
        url,
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_categoria': _categoriaSeleccionadaId,
          'nombre': _nombreController.text.trim(),
          'precio_detal': double.tryParse(_valorController.text.trim()) ?? 0.0,
          'precio_mayorista': double.tryParse(_precioMayoristaController.text.trim()),
          'presentacion': _presentacionController.text.trim().isNotEmpty ? _presentacionController.text.trim() : null,
          'cantidad': int.tryParse(_cantidadController.text.trim()) ?? 0,
          'cantidad_minima_mayorista': int.tryParse(_cantidadMinimaMayoristaController.text.trim()) ?? 0,
          'descripcion': _descripcionController.text.trim(),
          'imagen': imagenBase64, // Enviado como 'imagen' para que el backend lo procese y guarde
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Producto registrado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        _nombreController.clear();
        _valorController.clear();
        _precioMayoristaController.clear();
        _presentacionController.clear();
        _cantidadController.clear();
        _cantidadMinimaMayoristaController.clear();
        _descripcionController.clear();
        setState(() {
          _imagenProducto = null;
          _categoriaSeleccionadaId = null;
        });
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al registrar el producto');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
              (_) => false,
            ),
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ProductoFormContainer(
            nombreController: _nombreController,
            valorController: _valorController,
            precioMayoristaController: _precioMayoristaController,
            presentacionController: _presentacionController,
            cantidadController: _cantidadController,
            cantidadMinimaMayoristaController: _cantidadMinimaMayoristaController,
            descripcionController: _descripcionController,
            imagenProducto: _imagenProducto,
            onTapImagen: () async {
              final img = await _picker.pickImage(
                source: img_picker.ImageSource.gallery,
                maxWidth: 600,
                maxHeight: 600,
                imageQuality: 50,
              );
              if (img != null) setState(() => _imagenProducto = img);
            },
            categoriasList: _categoriasList,
            categoriaSeleccionadaId: _categoriaSeleccionadaId,
            onChangedCategoria: (id) =>
                setState(() => _categoriaSeleccionadaId = id),
            onAgregarCategoriaClick: _mostrarModalCrearCategoria,
            onGuardar: _guardarProducto,
            cargando: _cargando,
            cargandoCategorias: _cargandoCategorias,
          ),
        ),
      ),
    );
  }
}