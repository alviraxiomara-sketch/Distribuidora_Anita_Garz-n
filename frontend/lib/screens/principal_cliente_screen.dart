import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';
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

  void _abrirChatDistribuidora(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF032238),
      builder: (_) => const ChatDistribuidoraModal(),
    );
  }

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
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeHeaderBanner(),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Estamos listos para atenderte!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categorias.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) =>
                    CategoriaCard(categoria: categorias[index]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_chat_home',
        backgroundColor: const Color.fromARGB(255, 37, 168, 255),
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => _abrirChatDistribuidora(context),
        child: ClipOval(
          child: Image.asset(
            'assets/images/robot.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}