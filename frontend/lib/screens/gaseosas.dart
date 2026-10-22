import 'package:flutter/material.dart';
import 'package:frontend/screens/coca_cola.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/catalogo.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:frontend/widgets/home.dart';

class CatalogoProductosScreen extends StatelessWidget {
  const CatalogoProductosScreen({super.key});

  static const List<CategoriaItem> categorias = [
    CategoriaItem(nombre: 'Gaseosas', imagenAsset: 'assets/images/gaseosa.jpg'),
    CategoriaItem(nombre: 'Jugos', imagenAsset: 'assets/images/jugos.jpg'),
    CategoriaItem(nombre: 'Cervezas', imagenAsset: 'assets/images/cerveza.jpg'),
    CategoriaItem(nombre: 'Aguas', imagenAsset: 'assets/images/agua.jpg'),
    CategoriaItem(nombre: 'Lácteos', imagenAsset: 'assets/images/yogurd.jpg'),
    CategoriaItem(nombre: 'Energizantes', imagenAsset: 'assets/images/energizante.jpg'),
  ];

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
            const Text(
              'Gaseosas',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta Coca Cola conectada a CocaColaScreen
            ProductCardItem(
              nombre: 'Coca Cola',
              imagenAsset: 'assets/images/logo_coca_cola.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CocaColaScreen(),
                  ),
                );
              },
            ),

            // Tarjeta Pepsi
            ProductCardItem(
              nombre: 'Pepsi',
              imagenAsset: 'assets/images/logo_pepsi2.jpg',
              onTap: () {},
            ),

            // Tarjeta Postobón
            ProductCardItem(
              nombre: 'Postobón',
              imagenAsset: 'assets/images/logo_postobon.jpg',
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
    );
  }
}