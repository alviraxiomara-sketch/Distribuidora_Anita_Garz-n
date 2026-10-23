import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/carrito_service.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/cart_bottom_bar.dart';
import 'package:frontend/widgets/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _cargando = true;
  List<dynamic> _detallesCarrito = [];
  List<dynamic> _categoriasList = []; // <--- Variable declarada correctamente

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
    _cargarCategorias(); // <--- Método para cargar las categorías al iniciar
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
    } catch (_) {}
  }

  Future<void> _cargarCarrito() async {
    setState(() => _cargando = true);
    try {
      final carritoData = await CarritoService.obtenerCarrito();
      setState(() {
        _detallesCarrito = carritoData['detalle_carrito'] ?? [];
      });
    } on NoSesionException {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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

  Future<void> _cambiarCantidad(int index, int delta) async {
    final item = _detallesCarrito[index];
    final nuevaCantidad = item['cantidad'] + delta;
    if (nuevaCantidad <= 0) return;

    try {
      await CarritoService.actualizarCantidad(
        item['id_detalle_carrito'],
        nuevaCantidad,
      );
      _cargarCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarProducto(int index) async {
    final item = _detallesCarrito[index];
    try {
      await CarritoService.eliminarDetalle(item['id_detalle_carrito']);
      _cargarCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get _totalPagar {
    return _detallesCarrito.fold(0.0, (sum, item) {
      final subtotal = item['subtotal'] ?? 0;
      return sum +
          (subtotal is num
              ? subtotal.toDouble()
              : double.parse(subtotal.toString()));
    });
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
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
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
      drawer: AppDrawer(categorias: _categoriasList),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A8FF)),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Carrito de compras',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 25),
                        _detallesCarrito.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text(
                                  'Tu carrito está vacío',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _detallesCarrito.length,
                                itemBuilder: (context, index) {
                                  final item = _detallesCarrito[index];
                                  final producto = item['productos'] ?? {};
                                  return CartProductCardItem(
                                    index: index,
                                    nombre: producto['nombre'] ?? 'Producto',
                                    precioUnitario:
                                        (item['precio_unitario'] as num)
                                            .toDouble(),
                                    presentacion: 'Disponible',
                                    imagenAsset: 'assets/images/gaseosa.jpg',
                                    cantidad: item['cantidad'],
                                    seleccionado: true,
                                    onCantidadChanged: _cambiarCantidad,
                                    onToggleSeleccion: (_) {},
                                    onEliminar: _eliminarProducto,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                CartBottomBar(
                  totalPagar: _totalPagar,
                  isEmpty: _detallesCarrito.isEmpty,
                  onIniciarCompra: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Procesando compra...'),
                        backgroundColor: Color.fromARGB(255, 72, 180, 230),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}