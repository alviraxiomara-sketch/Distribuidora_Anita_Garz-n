import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/checkout_screen.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/carrito_service.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/cart_bottom_bar.dart';
import 'package:frontend/widgets/cart_product_list.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _cargando = true;
  List<dynamic> _detallesCarrito = [];
  List<dynamic> _categoriasList = [];

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
    _cargarCategorias();
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

  Future<void> _cargarCarrito({bool mostrarLoader = true}) async {
    if (mostrarLoader) setState(() => _cargando = true);
    try {
      final carritoData = await CarritoService.obtenerCarrito();
      final items = carritoData['detalle_carrito'] ?? [];
      
      // Inicializamos todos como seleccionados por defecto
      for (var item in items) {
        item['seleccionado'] = item['seleccionado'] ?? true;
      }

      setState(() {
        _detallesCarrito = items;
      });
    } on NoSesionException {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mostrarLoader && mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarCantidad(int index, int delta) async {
    final item = _detallesCarrito[index];
    final nuevaCantidad = item['cantidad'] + delta;
    if (nuevaCantidad <= 0) return;

    setState(() {
      _detallesCarrito[index]['cantidad'] = nuevaCantidad;
      final precio = (_detallesCarrito[index]['precio_unitario'] as num).toDouble();
      _detallesCarrito[index]['subtotal'] = precio * nuevaCantidad;
    });

    try {
      await CarritoService.actualizarCantidad(item['id_detalle_carrito'], nuevaCantidad);
      _cargarCarrito(mostrarLoader: false);
    } catch (e) {
      _cargarCarrito(mostrarLoader: false);
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.red);
    }
  }

  Future<void> _eliminarProducto(int index) async {
    final item = _detallesCarrito[index];
    setState(() => _detallesCarrito.removeAt(index));

    try {
      await CarritoService.eliminarDetalle(item['id_detalle_carrito']);
      _cargarCarrito(mostrarLoader: false);
    } catch (e) {
      _cargarCarrito(mostrarLoader: false);
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.red);
    }
  }

  // 👈 Método para actualizar el estado de selección de un producto y recalcular el total
  void _toggleSeleccion(int index, bool seleccionado) {
    setState(() {
      _detallesCarrito[index]['seleccionado'] = seleccionado;
    });
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // 👈 El total solo suma los productos cuyo 'seleccionado' sea true
  double get _totalPagar {
    return _detallesCarrito.fold(0.0, (sum, item) {
      final bool seleccionado = item['seleccionado'] ?? true;
      if (!seleccionado) return sum;

      final subtotal = item['subtotal'] ?? 0;
      return sum + (subtotal is num ? subtotal.toDouble() : double.parse(subtotal.toString()));
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
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(categorias: _categoriasList),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                        CartProductList(
                          detallesCarrito: _detallesCarrito,
                          onCantidadChanged: _cambiarCantidad,
                          onToggleSeleccion: _toggleSeleccion, // 👈 Conectado aquí
                          onEliminar: _eliminarProducto,
                        ),
                      ],
                    ),
                  ),
                ),
                CartBottomBar(
                  totalPagar: _totalPagar,
                  isEmpty: _detallesCarrito.isEmpty,
                  onIniciarCompra: () {
                    // 👈 Filtramos para enviar solo los productos que tengan el chulito marcado
                    final productosSeleccionados = _detallesCarrito
                        .where((item) => item['seleccionado'] == true)
                        .toList();

                    if (productosSeleccionados.isEmpty) {
                      _mostrarMensaje('Selecciona al menos un producto para continuar', Colors.red);
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          productosSeleccionados: productosSeleccionados,
                          totalPagar: _totalPagar,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}