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
import 'package:frontend/widgets/editar_producto.dart';

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
  Map<int, int> _catPorProducto = {}; // id_producto -> id_categoria
  bool _isLoading = true;
  int? _categoriaSel;
  bool _soloBajo = false;
  bool _soloAgotados = false;

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
    await Future.wait([
      _obtenerInventario(),
      _obtenerCategorias(),
      _obtenerMapaCategorias(),
    ]);
  }

  Future<void> _obtenerCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _categoriasList = jsonDecode(res.body));
      }
    } catch (_) {}
  }

  // Consulta /productos para saber la categoría de cada producto
  Future<void> _obtenerMapaCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/productos'),
        headers: {...ApiConfig.headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List lista = decoded is List
            ? decoded
            : (decoded['data'] ?? decoded['productos'] ?? []);
        final mapa = <int, int>{};
        for (final p in lista) {
          final idP = int.tryParse((p['id_producto'] ?? p['id'] ?? '').toString());
          final idC = int.tryParse((p['id_categoria'] ?? '').toString());
          if (idP != null && idC != null) mapa[idP] = idC;
        }
        if (mounted) setState(() => _catPorProducto = mapa);
        _filtrarInventario();
      }
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
        if (decoded is List) {
          temp = decoded;
        } else if (decoded is Map) {
          temp = decoded['data'] ?? decoded['inventario'] ?? [];
        }

        setState(() {
          _lista = temp;
          _isLoading = false;
        });
        _filtrarInventario();
        return;
      }
    } catch (_) {}
    _cargarDatosPrueba();
  }

  void _cargarDatosPrueba() {
    if (!mounted) return;
    setState(() {
      _lista = [
        {
          'id_inventario': 1,
          'id_producto': 101,
          'stock_actual': 30,
          'stock_minimo': 20,
          'productos': {
            'id_categoria': 1,
            'nombre': 'Aguila',
            'precio_detal': '3500',
            'presentacion': 'Botella'
          }
        }
      ];
      _filtrada = List.from(_lista);
      _isLoading = false;
    });
  }

  // ---------- Helpers de datos ----------
  int _aInt(dynamic v) => (num.tryParse(v?.toString() ?? '') ?? 0).round();
  int _stockActual(dynamic item) => _aInt(item['stock_actual'] ?? item['cantidad']);
  int _stockMinimo(dynamic item) => _aInt(item['stock_minimo'] ?? 20);
  bool _esStockBajo(dynamic item) => _stockActual(item) < _stockMinimo(item);
  bool _esAgotado(dynamic item) => _stockActual(item) <= 0;

  int? _idCategoria(dynamic item) {
    final p = item['productos'] ?? item;
    final directo =
        int.tryParse((p['id_categoria'] ?? item['id_categoria'] ?? '').toString());
    if (directo != null) return directo;
    final idProd = int.tryParse(
        (item['id_producto'] ?? p['id_producto'] ?? p['id'] ?? '').toString());
    return idProd == null ? null : _catPorProducto[idProd];
  }

  String? _nombreCategoria(dynamic item) {
    final p = item['productos'] ?? item;
    final embebida = p['categorias'] ?? p['categoria'];
    if (embebida is Map && embebida['nombre'] != null) {
      return embebida['nombre'].toString();
    }
    final id = _idCategoria(item);
    if (id == null) return null;
    for (final c in _categoriasList) {
      final cid = int.tryParse((c['id_categoria'] ?? c['id'] ?? '').toString());
      if (cid == id) return (c['nombre'] ?? c['nombre_categoria'])?.toString();
    }
    return null;
  }

  // Busca por nombre + filtros de categoría / stock bajo, y ordena A-Z
  void _filtrarInventario() {
    final query = _searchController.text.toLowerCase();

    final resultado = _lista.where((item) {
      if (item == null) return false;
      final p = item['productos'] ?? item;
      final nombre = (p['nombre'] ?? item['nombre'] ?? '').toString().toLowerCase();
      if (!nombre.contains(query)) return false;
      if (_categoriaSel != null && _idCategoria(item) != _categoriaSel) return false;
      // "Stock bajo" no incluye los agotados (igual que el resumen de arriba)
      if (_soloBajo && !(_stockActual(item) > 0 && _esStockBajo(item))) return false;
      if (_soloAgotados && !_esAgotado(item)) return false;
      return true;
    }).toList();

    resultado.sort((a, b) {
      final pa = a['productos'] ?? a;
      final pb = b['productos'] ?? b;
      final porNombre = (pa['nombre'] ?? '').toString().toLowerCase()
          .compareTo((pb['nombre'] ?? '').toString().toLowerCase());
      if (porNombre != 0) return porNombre;
      return _aInt(pa['precio_detal']).compareTo(_aInt(pb['precio_detal']));
    });

    if (mounted) setState(() => _filtrada = resultado);
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('¡Actualizado correctamente!'), backgroundColor: Colors.green));
      } else if (mounted) {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${err['error'] ?? 'No se pudo actualizar'}'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de red: $e'), backgroundColor: Colors.red));
      }
    } finally {
      await Future.wait([_obtenerInventario(), _obtenerMapaCategorias()]);
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

  Widget _chipFiltro(String label, bool activo, VoidCallback onTap,
      {Color color = const Color(0xFF00A8FF)}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? color : const Color(0xFF084B75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: activo ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chipFiltro('Todos', _categoriaSel == null && !_soloBajo && !_soloAgotados, () {
            _categoriaSel = null;
            _soloBajo = false;
            _soloAgotados = false;
            _filtrarInventario();
          }),
          _chipFiltro('Stock bajo', _soloBajo, () {
            _soloBajo = !_soloBajo;
            _soloAgotados = false;
            _filtrarInventario();
          }, color: const Color(0xFFFFA726)),
          _chipFiltro('Agotados', _soloAgotados, () {
            _soloAgotados = !_soloAgotados;
            _soloBajo = false;
            _filtrarInventario();
          }, color: Colors.redAccent),
          for (final c in _categoriasList)
            () {
              final id = int.tryParse((c['id_categoria'] ?? c['id'] ?? '').toString());
              final nombre = (c['nombre'] ?? c['nombre_categoria'] ?? '').toString();
              return _chipFiltro(nombre, _categoriaSel == id, () {
                _categoriaSel = _categoriaSel == id ? null : id;
                _filtrarInventario();
              });
            }(),
        ],
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
        leadingWidth: 112,
        leading: Row(children: [
          const SizedBox(width: 6),
          IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()))),
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
          IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
              const SizedBox(height: 14),
              InventarioResumen(
                total: _lista.length,
                bajos: _lista.where((i) => _stockActual(i) > 0 && _esStockBajo(i)).length,
                agotados: _lista.where((i) => _stockActual(i) <= 0).length,
              ),
              const SizedBox(height: 14),
              _buildFiltros(),
              const SizedBox(height: 16),
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                  : _filtrada.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No se encontraron productos',
                              style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filtrada.length,
                          itemBuilder: (_, i) => InventarioItemCard(
                            producto: _filtrada[i],
                            categoria: _nombreCategoria(_filtrada[i]),
                            onEditar: () => _abrirModalEditar(_filtrada[i]),
                          ),
                        ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const IngresarProductoScreen())),
                  child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}