import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';
import 'package:frontend/widgets/admin_drawer.dart'; // <--- Importante: Usamos el AdminDrawer[cite: 11]
import 'package:frontend/widgets/home.dart';
import 'package:frontend/widgets/admin.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';

class PrincipalAdminScreen extends StatefulWidget {
  const PrincipalAdminScreen({super.key});

  @override
  State<PrincipalAdminScreen> createState() => _PrincipalAdminScreenState();
}

class _PrincipalAdminScreenState extends State<PrincipalAdminScreen> {
  bool _verificandoRol = true;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _validarPermisoAdmin();
  }

  Future<void> _validarPermisoAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioString = prefs.getString('usuario');

      if (usuarioString != null && usuarioString.isNotEmpty) {
        final Map<String, dynamic> usuarioMap = jsonDecode(usuarioString);
        final rol = usuarioMap['rol'] ?? usuarioMap['tipo_usuario'] ?? '';

        if (rol.toString().toUpperCase() == 'ADMIN') {
          setState(() {
            _esAdmin = true;
            _verificandoRol = false;
          });
          return;
        }
      }
      _denegarAcceso();
    } catch (e) {
      _denegarAcceso();
    }
  }

  void _denegarAcceso() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acceso restringido solo para administradores'), backgroundColor: Colors.red),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_verificandoRol) {
      return const Scaffold(
        backgroundColor: Color(0xFF031A2E),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF))),
      );
    }

    if (!_esAdmin) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AdminDrawer(), // <--- Llamado limpio sin categorías
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const HomeHeaderBanner(),
            const SizedBox(height: 30),
            const AdminNoticeCard(),
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
                border: Border.all(color: const Color(0xFF00A8FF).withOpacity(0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión del Sistema',
                    style: TextStyle(color: Color(0xFF00A8FF), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                  ),
                  SizedBox(height: 16),
                  AdminBenefitRow(icon: Icons.inventory_rounded, title: 'Control de Inventario', subtitle: 'Supervisa existencias y stock de productos.'),
                  SizedBox(height: 14),
                  AdminBenefitRow(icon: Icons.local_shipping_outlined, title: 'Seguimiento de Pedidos', subtitle: 'Administra las solicitudes y entregas en curso.'),
                  SizedBox(height: 14),
                  AdminBenefitRow(icon: Icons.people_alt_outlined, title: 'Gestión de Clientes', subtitle: 'Revisa registros y perfiles de usuarios activos.'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooterContacts(isAdmin: true),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_chat_home_admin',
        backgroundColor: const Color(0xFF00A8FF),
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF032238),
          builder: (_) => const ChatDistribuidoraModal(),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/robot.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}