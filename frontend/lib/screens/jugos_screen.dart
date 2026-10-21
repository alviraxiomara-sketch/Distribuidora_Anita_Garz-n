import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/hit_products_screen.dart';
import 'package:frontend/screens/login_screen.dart'; // <--- IMPORT DE LOGIN
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:frontend/widgets/home_widgets.dart';
import 'package:frontend/widgets/jugos_widgets.dart';

class JugosScreen extends StatelessWidget {
  const JugosScreen({super.key});

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
          // ICONO DE PERSONA CONECTADO A LOGIN
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
            const Text(
              'Jugos',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            JugoCategoryCard(
              nombre: 'Hit De Caja',
              imagenAsset: 'assets/images/logo_hit.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HitProductsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            JugoCategoryCard(
              nombre: 'cifrut',
              imagenAsset: 'assets/images/logo_cifrut.jpg',
              onTap: () {},
            ),
            const SizedBox(height: 16),

            JugoCategoryCard(
              nombre: 'Tuti Fruti',
              imagenAsset: 'assets/images/logo_tutti_frutti.jpg',
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