import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/home_widgets.dart';

class PrincipalClienteScreen extends StatelessWidget {
  const PrincipalClienteScreen({super.key});

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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Habilita el icono del menú hamburguesa
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
      drawer: const AppDrawer(categorias: categorias),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const HomeHeaderBanner(),
            const SizedBox(height: 30),

            // Tarjeta de aviso estilizada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF063B5D).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00A8FF).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    color: Color(0xFF00A8FF),
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '¡Estamos listos para atenderte!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SECCIÓN CENTRAL: Destacados / Beneficios (Igual a HomeScreen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF063B5D), Color(0xFF032238)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00A8FF).withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Por qué elegirnos?',
                    style: TextStyle(
                      color: Color(0xFF00A8FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitRow(
                    Icons.speed_rounded,
                    'Entregas Rápidas',
                    'Despachos oportunos para tu negocio o evento.',
                  ),
                  const SizedBox(height: 14),
                  _buildBenefitRow(
                    Icons.inventory_2_outlined,
                    'Variedad Garantizada',
                    'Amplio catálogo en gaseosas, cervezas, jugos y más.',
                  ),
                  const SizedBox(height: 14),
                  _buildBenefitRow(
                    Icons.verified_outlined,
                    'Precios Especiales',
                    'Atención directa y las mejores tarifas de distribución.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_chat_home_cliente',
        backgroundColor: const Color(0xFF00A8FF),
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () => _abrirChatDistribuidora(context),
        child: ClipOval(
          child: Image.asset(
            'assets/images/robot.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF031A2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00A8FF).withOpacity(0.5)),
          ),
          child: Icon(icon, color: const Color(0xFF00A8FF), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
