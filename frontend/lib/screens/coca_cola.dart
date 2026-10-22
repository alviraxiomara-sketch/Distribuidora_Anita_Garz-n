import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/services/carrito_helper.dart'; // <--- IMPORTANTE: Importamos el helper
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/coca_cola.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:frontend/widgets/home.dart';

class CocaColaScreen extends StatefulWidget {
  const CocaColaScreen({super.key});

  @override
  State<CocaColaScreen> createState() => _CocaColaScreenState();
}

class _CocaColaScreenState extends State<CocaColaScreen> {
  // Estado independiente para la cantidad de cada presentación (índices 0, 1, 2 y 3)
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
            onPressed: () {},
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
              'Coca Cola',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Producto 1 (Cambia el '1' por el id_producto real en tu BD)
            CocaColaProductCardItem(
              index: 0,
              nombre: 'Coca Cola',
              precio: '\$12.000',
              presentacion: '1/2 L Plástico',
              imagenAsset: 'assets/images/gaseosa.jpg',
              cantidad: _cantidades[0] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: () {
                manejarAgregarAlCarrito(
                  context,
                  1, // <--- Reemplaza con el ID real de Coca Cola en la tabla 'productos'
                  _cantidades[0] ?? 1,
                );
              },
            ),

            // Producto 2 (Cambia el '2' por el id_producto real en tu BD)
            CocaColaProductCardItem(
              index: 1,
              nombre: 'Sprite',
              precio: '\$15.000',
              presentacion: '1.5 L Plástico',
              imagenAsset: 'assets/images/sprite.jpg',
              cantidad: _cantidades[1] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: () {
                manejarAgregarAlCarrito(
                  context,
                  2, // <--- Reemplaza con el ID real de Sprite en la tabla 'productos'
                  _cantidades[1] ?? 1,
                );
              },
            ),

            // Producto 3 (Cambia el '3' por el id_producto real en tu BD)
            CocaColaProductCardItem(
              index: 2,
              nombre: 'Fanta Naranja',
              precio: '\$18.000',
              presentacion: '3 L Plástico',
              imagenAsset: 'assets/images/fanta.jpg',
              cantidad: _cantidades[2] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: () {
                manejarAgregarAlCarrito(
                  context,
                  3, // <--- Reemplaza con el ID real de Fanta Naranja en la tabla 'productos'
                  _cantidades[2] ?? 1,
                );
              },
            ),

            // Producto 4 (Cambia el '4' por el id_producto real en tu BD)
            CocaColaProductCardItem(
              index: 3,
              nombre: 'Quatro Toronja',
              precio: '\$18.000',
              presentacion: '1.5 L Plástico',
              imagenAsset: 'assets/images/Quatro.jpg',
              cantidad: _cantidades[3] ?? 1,
              onCantidadChanged: _cambiarCantidad,
              onAgregarAlCarrito: () {
                manejarAgregarAlCarrito(
                  context,
                  4, // <--- Reemplaza con el ID real de Quatro Toronja en la tabla 'productos'
                  _cantidades[3] ?? 1,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
    );
  }
}