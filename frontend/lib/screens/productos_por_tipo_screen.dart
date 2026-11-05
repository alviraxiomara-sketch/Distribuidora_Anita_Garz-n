import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/producto_card.dart';

class ProductosPorTipoScreen extends StatefulWidget {
  final String categoria; 
  final String tipo;      

  const ProductosPorTipoScreen({
    super.key,
    required this.categoria,
    required this.tipo,
  });

  @override
  State<ProductosPorTipoScreen> createState() => _ProductosPorTipoScreenState();
}

class _ProductosPorTipoScreenState extends State<ProductosPorTipoScreen> {
  bool _cargando = true;
  bool _cargandoProductos = true;
  List<dynamic> _categoriasList = [];
  List<dynamic> _productosList = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarProductosDesdeBD();
  }

  Future<void> _cargarCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        setState(() {
          _categoriasList = decoded is List ? decoded : [];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _cargarProductosDesdeBD() async {
    setState(() => _cargandoProductos = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/productos'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        List<dynamic> lista = [];
        
        if (decoded is List) {
          lista = decoded;
        } else if (decoded is Map) {
          var temp = decoded['productos'] ?? decoded['data'] ?? [];
          if (temp is List) lista = temp;
        }

        // 🔍 Filtrado estricto por Tipo y Categoría simultáneamente
        final listaFiltrada = lista.where((prod) {
          if (prod == null || prod is! Map) return false;
          
          final tipoProd = prod['tipo']?.toString().trim().toLowerCase() ?? '';
          final tipoBuscado = widget.tipo.trim().toLowerCase();

          final catProd = (prod['categorias']?['nombre'] ?? prod['categoria'] ?? '').toString().trim().toLowerCase();
          final catBuscada = widget.categoria.trim().toLowerCase();

          bool coincideTipo = tipoProd == tipoBuscado;
          bool coincideCategoria = catProd.isEmpty || catProd == catBuscada;

          return coincideTipo && coincideCategoria;
        }).toList();

        setState(() {
          _productosList = listaFiltrada;
          _cargandoProductos = false;
        });
      } else {
        setState(() => _cargandoProductos = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoProductos = false);
      }
    }
  }

  // 🛒 Manejo de sesión y guardado en el carrito de compras
  Future<void> _manejarAgregarCarrito(Map<String, dynamic> producto, int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    // Si no ha iniciado sesión, redirigir al Login
    if (token == null || token.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final idProducto = producto['id_producto'] ?? producto['id'];

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/carrito'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_producto': idProducto,
          'cantidad': cantidad,
        }),
      );

      if (!mounted) return;

      // Validamos si el backend aceptó el registro en el carrito (200 o 201)
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto agregado al carrito'),
            backgroundColor: Color(0xFF063B5D),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Mostramos el mensaje exacto que devuelva el servidor de Render si ocurre un error
        String mensajeBackend = 'Error (${res.statusCode})';
        try {
          final decoded = jsonDecode(res.body);
          mensajeBackend = decoded['mensaje'] ?? decoded['error'] ?? res.body;
        } catch (_) {
          mensajeBackend = res.body.isNotEmpty ? res.body : 'Error del servidor';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeBackend),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _verificarSesionYRedirigirHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _verificarSesionYRedirigirPerfil(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloDinamico = '${widget.categoria} ${widget.tipo}';

    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _verificarSesionYRedirigirHome(context),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
          ),
          IconButton(
            onPressed: () => _verificarSesionYRedirigirPerfil(context),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(categorias: _categoriasList, isLoading: _cargando),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              tituloDinamico,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00A8FF).withOpacity(0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF063B5D).withOpacity(0.3),
                ),
                child: _cargandoProductos
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                    : _productosList.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay productos registrados en esta categoría',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _productosList.length,
                            itemBuilder: (context, index) {
                              final producto = _productosList[index];

                              return ProductoCard(
                                nombre: producto['nombre'] ?? 'Sin nombre',
                                precioDetal: producto['precio_detal'] != null 
                                    ? "\$${producto['precio_detal']}" 
                                    : "\$0",
                                presentacion: producto['presentacion'] ?? '',
                                tapa: producto['tapa'] ?? '',
                                imagenUrl: producto['imagen_url'] ?? '',
                                onAgregarCarrito: (cantidadSeleccionada) {
                                  _manejarAgregarCarrito(producto, cantidadSeleccionada);
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}