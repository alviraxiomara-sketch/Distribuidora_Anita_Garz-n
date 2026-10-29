import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/notificaciones_cliente.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/cart.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/home.dart';

class PrincipalClienteScreen extends StatefulWidget {
  const PrincipalClienteScreen({super.key});

  @override
  State<PrincipalClienteScreen> createState() => _PrincipalClienteScreenState();
}

class _PrincipalClienteScreenState extends State<PrincipalClienteScreen> {
  List<dynamic> _categoriasList = [];

  @override
  void initState() {
    super.initState();
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

  void _abrirChat(BuildContext context) {
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 2. Conectar el botón de la campana con NotificacionesScreen
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 26,
            ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const HomeHeaderBanner(),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF063B5D).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00A8FF).withOpacity(0.5),
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
      bottomNavigationBar: const HomeFooterContacts(isAdmin: false),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_chat_home_cliente',
        backgroundColor: const Color(0xFF00A8FF),
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () => _abrirChat(context),
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
