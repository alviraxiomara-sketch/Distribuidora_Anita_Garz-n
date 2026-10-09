import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<CategoriaItem> categorias = [
    CategoriaItem(nombre: 'Gaseosas', imagenAsset: 'assets/images/gaseosa.jpg'),
    CategoriaItem(nombre: 'Jugos', imagenAsset: 'assets/images/jugos.jpg'),
    CategoriaItem(nombre: 'Cervezas', imagenAsset: 'assets/images/cerveza.jpg'),
    CategoriaItem(nombre: 'Aguas', imagenAsset: 'assets/images/agua.jpg'),
    CategoriaItem(nombre: 'Lácteos', imagenAsset: 'assets/images/yogurd.jpg'),
    CategoriaItem(
      nombre: 'Energizantes',
      imagenAsset: 'assets/images/energizante.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const HomeHeaderBanner(),
            const SizedBox(height: 20),
            const Text(
              '¡Estamos listos para atenderte!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF084B75),
              alignment: Alignment.center,
              child: const Text(
                'Categorías',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categorias.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) =>
                  CategoriaCard(categoria: categorias[index]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
    );
  }
}