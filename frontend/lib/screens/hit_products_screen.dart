import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:frontend/widgets/home_widgets.dart';
import 'package:frontend/widgets/coca_cola_widgets.dart';
import 'package:frontend/screens/login_screen.dart'; 

class HitProductsScreen extends StatefulWidget {
  const HitProductsScreen({super.key});

  @override
  State<HitProductsScreen> createState() => _HitProductsScreenState();
}

class _HitProductsScreenState extends State<HitProductsScreen> {
  // Estado para la cantidad de cada producto
  final Map<int, int> _cantidades = {0: 1, 1: 1, 2: 1, 3: 1};

  static const List<CategoriaItem> categorias = [
    CategoriaItem(nombre: 'Gaseosas', imagenAsset: 'assets/images/gaseosa.jpg'),
    CategoriaItem(nombre: 'Jugos', imagenAsset: 'assets/images/jugos.jpg'),
    CategoriaItem(nombre: 'Cervezas', imagenAsset: 'assets/images/cerveza.jpg'),
    CategoriaItem(nombre: 'Aguas', imagenAsset: 'assets/images/agua.jpg'),
    CategoriaItem(nombre: 'Lácteos', imagenAsset: 'assets/images/yogurd.jpg'),
    CategoriaItem(nombre: 'Energizantes', imagenAsset: 'assets/images/energizante.jpg'),
  ];

  void _cambiarCantidad(int index, int delta) {
    setState(() {
      final actual = _cantidades[index] ?? 1;
      final nuevo = actual + delta;
      if (nuevo >= 1) {
        _cantidades[index] = nuevo;
      }
    });
  }

  // Método centralizado para mostrar un solo mensaje al agregar al carrito
  void _mostrarMensajeCarrito() {
    ScaffoldMessenger.of(context).clearSnackBars(); // Oculta mensajes previos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto agregado al carrito'),
        backgroundColor: Color.fromARGB(255, 72, 180, 230),
        duration: Duration(seconds: 2),
      ),
    );
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
          // Icono de Casa para volver a la pantalla principal
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          // Icono de Perfil
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(categorias: categorias),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Título de la pantalla
            const Text(
              'Jugos Hit',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Producto 1
            CocaColaProductCardItem(
              index: 0,
              nombre: 'Hit de Mango',
              precio: '\$15.000',
              presentacion: 'Caja  de 1L',
              imagenAsset: 'assets/images/hit_mango.jpg',
              cantidad: _cantidades[0] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: _mostrarMensajeCarrito,
            ),

            // Producto 2
            CocaColaProductCardItem(
              index: 1,
              nombre: 'Hit de Mora ',
              precio: '\$15.000',
              presentacion: 'Caja  de 1L',
              imagenAsset: 'assets/images/hit_mora.jpg',
              cantidad: _cantidades[1] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: _mostrarMensajeCarrito,
            ),

            // Producto 3
            CocaColaProductCardItem(
              index: 2,
              nombre: 'Hit de Lulo 1L',
              precio: '\$15.000',
              presentacion: 'Caja  de 1L',
              imagenAsset: 'assets/images/hit_lulo.jpg',
              cantidad: _cantidades[2] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: _mostrarMensajeCarrito,
            ),

            // Producto 4
            CocaColaProductCardItem(
              index: 3,
              nombre: 'Hit Frutas Tropicales 1L',
              precio: '\$15.000',
              presentacion: 'Caja  de 1L',
              imagenAsset: 'assets/images/hit_tropical.jpg',
              cantidad: _cantidades[3] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: _mostrarMensajeCarrito,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
    );
  }
}