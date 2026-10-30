import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart'; // <--- Corregido al Drawer de Administrador
import 'package:frontend/widgets/producto_ingresar_form.dart';

class IngresarProductoScreen extends StatefulWidget {
  const IngresarProductoScreen({super.key});

  @override
  State<IngresarProductoScreen> createState() => _IngresarProductoScreenState();
}

class _IngresarProductoScreenState extends State<IngresarProductoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nombreController = TextEditingController();
  final _valorController = TextEditingController();
  final _precioMayoristaController = TextEditingController();
  final _presentacionController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _cantidadMinimaMayoristaController = TextEditingController();

  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  img_picker.XFile? _imagenProducto;

  bool _cargando = false;
  bool _cargandoCategorias = true;
  bool _cargandoTipos = false;
  
  List<dynamic> _categoriasList = [];
  List<dynamic> _tiposList = [];
  
  int? _categoriaSeleccionadaId;
  int? _tipoSeleccionadoId;
  String? _tapaSeleccionada; 

  @override
  void initState() {
    super.initState();
    _cargarCategoriasDesdeBD();
    _cargarTodosLosTipos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _valorController.dispose();
    _precioMayoristaController.dispose();
    _presentacionController.dispose();
    _cantidadController.dispose();
    _cantidadMinimaMayoristaController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategoriasDesdeBD() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && mounted) {
        final decoded = jsonDecode(response.body);
        List<dynamic> lista = decoded is List ? decoded : (decoded['categorias'] ?? decoded['data'] ?? []);
        setState(() {
          _categoriasList = lista;
          _cargandoCategorias = false;
        });
      } else if (mounted) {
        setState(() => _cargandoCategorias = false);
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoCategorias = false);
    }
  }

  Future<void> _cargarTodosLosTipos() async {
    setState(() => _cargandoTipos = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tipos'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && mounted) {
        final decoded = jsonDecode(response.body);
        List<dynamic> lista = decoded is List ? decoded : (decoded['tipos'] ?? decoded['data'] ?? []);
        setState(() {
          _tiposList = lista;
          _cargandoTipos = false;
        });
      } else {
        setState(() {
          _tiposList = [{'id': 1, 'nombre': 'Nacionales'}, {'id': 2, 'nombre': 'Importadas'}];
          _cargandoTipos = false;
        });
      }
    } catch (e) {
      setState(() {
        _tiposList = [{'id': 1, 'nombre': 'Nacionales'}, {'id': 2, 'nombre': 'Importadas'}];
        _cargandoTipos = false;
      });
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

  Future<void> _ejecutarGuardado() async {
    final nombre = _nombreController.text.trim();
    final valor = _valorController.text.trim();

    if (nombre.isEmpty || valor.isEmpty || _categoriaSeleccionadaId == null || _tipoSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos obligatorios, categoría y tipo'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final token = (await SharedPreferences.getInstance()).getString('token');
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/productos'));

      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = nombre;
      request.fields['precio_detal'] = valor;
      request.fields['precio_mayorista'] = _precioMayoristaController.text.trim().isEmpty ? '0' : _precioMayoristaController.text.trim();
      request.fields['presentacion'] = _presentacionController.text.trim();
      request.fields['tapa'] = _tapaSeleccionada ?? ''; 
      request.fields['cantidad'] = _cantidadController.text.trim().isEmpty ? '0' : _cantidadController.text.trim();
      request.fields['cantidad_minima_mayorista'] = _cantidadMinimaMayoristaController.text.trim().isEmpty ? '0' : _cantidadMinimaMayoristaController.text.trim();
      request.fields['id_categoria'] = _categoriaSeleccionadaId.toString();
      
      final tipoEncontrado = _tiposList.firstWhere(
        (t) => (int.tryParse((t['id_tipo'] ?? t['id'])?.toString() ?? '0') ?? 0) == _tipoSeleccionadoId,
        orElse: () => {'nombre': 'Nacionales'},
      );
      request.fields['tipo'] = tipoEncontrado['nombre'] ?? 'Nacionales';

      if (_imagenProducto != null) {
        if (kIsWeb) {
          var bytes = await _imagenProducto!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('imagen', bytes, filename: _imagenProducto!.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('imagen', _imagenProducto!.path));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado exitosamente'), backgroundColor: Colors.green),
        );
        _nombreController.clear();
        _valorController.clear();
        _precioMayoristaController.clear();
        _presentacionController.clear();
        _cantidadController.clear();
        _cantidadMinimaMayoristaController.clear();
        setState(() {
          _imagenProducto = null;
          _categoriaSeleccionadaId = null;
          _tipoSeleccionadoId = null;
          _tapaSeleccionada = null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      drawer: const AdminDrawer(), // <--- Actualizado al Drawer exclusivo del Administrador
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 130,
        leading: Row(
          children: [
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()),
                (_) => false,
              ),
            ),
          ],
        ),
        actions: [
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
            tapaSeleccionada: _tapaSeleccionada,
            onChangedTapa: (val) => setState(() => _tapaSeleccionada = val),
            imagenProducto: _imagenProducto,
            onTapImagen: () async {
              final img = await _picker.pickImage(source: img_picker.ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 50);
              if (img != null) setState(() => _imagenProducto = img);
            },
            categoriasList: _categoriasList,
            categoriaSeleccionadaId: _categoriaSeleccionadaId,
            onChangedCategoria: (id) => setState(() => _categoriaSeleccionadaId = id),
            tiposList: _tiposList,
            tipoSeleccionadoId: _tipoSeleccionadoId,
            onChangedTipo: (id) => setState(() => _tipoSeleccionadoId = id),
            cargandoTipos: _cargandoTipos,
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