import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart'; // <--- Importado el AdminDrawer
import 'package:frontend/widgets/ingresar_producto.dart';
import 'package:frontend/widgets/producto_ingresar_form_state.dart';

class IngresarProductoScreen extends StatefulWidget {
  const IngresarProductoScreen({super.key});

  @override
  State<IngresarProductoScreen> createState() => _IngresarProductoScreenState();
}

class _IngresarProductoScreenState extends State<IngresarProductoScreen> {
  // Clave para controlar la apertura del menú lateral (Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _categoriasList = jsonDecode(response.body);
          _cargandoCategorias = false;
        });
      } else if (mounted) {
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
        title: const Text('Nueva Categoría', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: nuevaCatController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A8FF)),
            onPressed: () async {
              if (nuevaCatController.text.trim().isEmpty) return;
              try {
                final token = (await SharedPreferences.getInstance()).getString('token');
                final res = await http.post(
                  Uri.parse('${ApiConfig.baseUrl}/categorias'),
                  headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
                  body: jsonEncode({'nombre': nuevaCatController.text.trim()}),
                );
                if (res.statusCode == 201 || res.statusCode == 200) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  await _cargarCategoriasDesdeBD();
                }
              } catch (_) {}
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _ejecutarGuardado() {
    ProductoFormControllerHelper.guardarProducto(
      context: context,
      nombreController: _nombreController,
      valorController: _valorController,
      precioMayoristaController: _precioMayoristaController,
      presentacionController: _presentacionController,
      cantidadController: _cantidadController,
      cantidadMinimaMayoristaController: _cantidadMinimaMayoristaController,
      descripcionController: _descripcionController,
      categoriaSeleccionadaId: _categoriaSeleccionadaId,
      imagenProducto: _imagenProducto,
      onCargando: (val) => setState(() => _cargando = val),
      onExito: () => setState(() {
        _imagenProducto = null;
        _categoriaSeleccionadaId = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      
      // Menú lateral del Administrador
      drawer: const AdminDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        automaticallyImplyLeading: false, // Oculta la flecha por defecto
        
        // Ancho y distribución de los botones izquierdos (menú hamburguesa + casita)
        leadingWidth: 110,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            // 1. Botón de Menú Hamburguesa para abrir el Drawer
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(width: 16), // Espaciado entre la hamburguesa y la casita
            // 2. Botón de la Casita para regresar al panel de administrador
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()),
                (_) => false,
              ),
            ),
          ],
        ),
        actions: [
          // Botón de Perfil
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
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
              final img = await _picker.pickImage(source: img_picker.ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 50);
              if (img != null) setState(() => _imagenProducto = img);
            },
            categoriasList: _categoriasList,
            categoriaSeleccionadaId: _categoriaSeleccionadaId,
            onChangedCategoria: (id) => setState(() => _categoriaSeleccionadaId = id),
            onAgregarCategoriaClick: _mostrarModalCrearCategoria,
            onGuardar: _ejecutarGuardado,
            cargando: _cargando,
            cargandoCategorias: _cargandoCategorias,
          ),
        ),
      ),
    );
  }
}