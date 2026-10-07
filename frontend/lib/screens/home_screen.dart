import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';

class CategoriaItem {
  final String nombre;
  final String imagenAsset;
  const CategoriaItem({required this.nombre, required this.imagenAsset});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<CategoriaItem> categorias = [
    CategoriaItem(nombre: 'Gaseosas', imagenAsset: 'assets/images/gaseosa.jpg'),
    CategoriaItem(nombre: 'Jugos', imagenAsset: 'assets/images/jugos.jpg'),
    CategoriaItem(nombre: 'Cervezas', imagenAsset: 'assets/images/cerveza.jpg'),
    CategoriaItem(nombre: 'Aguas', imagenAsset: 'assets/images/agua.jpg'),
    CategoriaItem(nombre: 'Lácteos', imagenAsset: 'assets/images/yogurd.jpg'),
    CategoriaItem(nombre: 'Energizantes', imagenAsset: 'assets/images/energizante.jpg'),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }, 
            icon: const Icon(Icons.login_outlined, color: Colors.white, size: 22),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            }, 
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF00A8FF), shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.local_drink, color: Color(0xFF031A2E), size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    children: [
                      Text('Bienvenidos a distribuciones\nde bebidas Anita', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.white)),
                      SizedBox(height: 10),
                      Text('Tu mejor opción en\npedidos y distribuciones de\nbebidas', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color.fromARGB(214, 255, 255, 255))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('¡Estamos listos para atenderte!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 17)),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF084B75),
              alignment: Alignment.center,
              child: const Text('Categorías', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categorias.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 10, childAspectRatio: 0.85),
              itemBuilder: (context, index) => _CategoriaCard(categoria: categorias[index]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        color: const Color(0xFF084B75),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contactos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 4),
            Row(children: [Icon(Icons.call, color: Colors.white70, size: 14), SizedBox(width: 6), Text('3227328596', style: TextStyle(color: Colors.white, fontSize: 12))]),
            SizedBox(height: 2),
            Row(children: [Icon(Icons.location_on, color: Colors.white70, size: 14), SizedBox(width: 6), Text('calle 4 a sur #16-05', style: TextStyle(color: Colors.white, fontSize: 12))]),
          ],
        ),
      ),
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
            errorBuilder: (_, __, ___) => const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final CategoriaItem categoria;
  const _CategoriaCard({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00A8FF), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(categoria.imagenAsset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(categoria.nombre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    );
  }
}