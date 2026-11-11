import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/notificaciones_cliente.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/cart_screen.dart';
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
  int _noLeidasCount = 0; // <--- Variable para almacenar el número de notificaciones no leídas

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _contarNotificacionesNoLeidas();
  }

  // Método para actualizar las notificaciones al volver de la pantalla de notificaciones
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contarNotificacionesNoLeidas();
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

  // Consultar cuántas notificaciones no leídas tiene el cliente
  Future<void> _contarNotificacionesNoLeidas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        List<dynamic> lista = [];
        if (decoded is List) {
          lista = decoded;
        } else if (decoded is Map) {
          lista = decoded['data'] ?? decoded['notificaciones'] ?? [];
        }

        // Filtramos las que tengan leida == false (o leida == 0 / null)
        int noLeidas = lista.where((item) {
          final leida = item['leida'] ?? item['leido'] ?? false;
          return leida == false || leida == 0;
        }).length;

        setState(() {
          _noLeidasCount = noLeidas;
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
          // Botón de campana con indicador dinámico (Badge)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  // Al presionar, navegamos a NotificacionesCliente
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificacionesCliente()),
                  );
                  // Al regresar, recalculamos las no leídas para que el número desaparezca/se actualice
                  _contarNotificacionesNoLeidas();
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              if (_noLeidasCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_noLeidasCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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