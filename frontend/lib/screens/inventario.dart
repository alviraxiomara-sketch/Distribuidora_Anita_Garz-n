import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/ingresar_producto.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart';
import 'package:frontend/widgets/inventario.dart';
import 'package:frontend/widgets/editar_producto.dart'; // <--- Importamos el nuevo widget de diálogo

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  
  List<dynamic> _lista = [];
  List<dynamic> _filtrada = [];
  List<dynamic> _categoriasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
    _searchController.addListener(_filtrarInventario);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    await Future.wait([_obtenerInventario(), _obtenerCategorias()]);
  }

  Future<void> _obtenerCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200 && mounted) setState(() => _categoriasList = jsonDecode(res.body));
    } catch (_) {}
  }

  Future<void> _obtenerInventario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/inventario'),
        headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        List<dynamic> temp = [];
        if (decoded is List) temp = decoded;
        else if (decoded is Map) temp = decoded['data'] ?? decoded['inventario'] ?? [];

        setState(() { _lista = temp; _filtrada = List.from(temp); _isLoading = false; });
        return;
      }
    } catch (_) {}
    _cargarDatosPrueba();
  }

  void _cargarDatosPrueba() {
    if (!mounted) return;
    setState(() {
      _lista = [{'id_inventario': 1, 'id_producto': 101, 'stock_actual': 30, 'stock_minimo': 20, 'productos': {'id_categoria': 1, 'nombre': 'Aguila', 'precio_detal': '3500', 'presentacion': 'Botella'}}];
      _filtrada = List.from(_lista);
      _isLoading = false;
    });
  }

  void _filtrarInventario() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtrada = _lista.where((item) {
        if (item == null) return false;
        final p = item['productos'] ?? item;
        return (p['nombre'] ?? item['nombre'] ?? '').toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _actualizarProductoEnBD({
    required int? idProd,
    required int? idCat,
    required String nombre,
    required String precio,
    required String presentacion,
    required int stock,
    img_picker.XFile? imagen,
  }) async {
    if (idProd == null) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.baseUrl}/productos/$idProd'));
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = nombre;
      request.fields['precio_detal'] = precio;
      request.fields['presentacion'] = presentacion;
      if (idCat != null) request.fields['id_categoria'] = idCat.toString();
      request.fields['stock_actual'] = stock.toString();

      if (imagen != null) {
        if (kIsWeb) {
          final bytes = await imagen.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('imagen', bytes, filename: imagen.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));
        }
      }

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Actualizado correctamente!'), backgroundColor: Colors.green));
      } else if (mounted) {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${err['error'] ?? 'No se pudo actualizar'}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de red: $e'), backgroundColor: Colors.red));
    } finally {
      await _obtenerInventario();
    }
  }

  void _abrirModalEditar(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => EditarProductoDialog(
        item: item,
        categoriasList: _categoriasList,
        onGuardar: _actualizarProductoEnBD,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        leadingWidth: 100,
        leading: Row(children: [
          const SizedBox(width: 6),
          IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          IconButton(icon: const Icon(Icons.home_outlined, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()))),
        ]),
        title: Container(
          height: 38,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Buscar Producto',
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle_outlined, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF384E5E).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00A8FF), width: 2),
          ),
          child: Column(
            children: [
              const BadgeInventario(),
              const SizedBox(height: 20),
              _isLoading
                  ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                  : _filtrada.isEmpty
                      ? const Padding(padding: EdgeInsets.all(40), child: Text('No se encontraron productos', style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filtrada.length,
                          itemBuilder: (_, i) => InventarioItemCard(
                            producto: _filtrada[i],
                            onEditar: () => _abrirModalEditar(_filtrada[i]),
                          ),
                        ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IngresarProductoScreen())),
                  child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}