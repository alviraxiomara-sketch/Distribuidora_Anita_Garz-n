import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _cerrarSesion() {
    // TODO: limpiar sesión (token) y navegar al login.
  }

  Widget _icono(IconData icono) =>
      Icon(icono, color: Colors.white, size: 22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _icono(Icons.home_outlined),
                  _icono(Icons.notifications_none),
                  _icono(Icons.shopping_cart_outlined),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt_outlined,
                            color: kFondoOscuro),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: tarjetaDecoration(),
                        child: Column(
                          children: [
                            const Text(
                              'Perfil',
                              style: TextStyle(
                                color: kTextoClaro,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nombreCtrl,
                              decoration: campoDecoration('Nombre'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _correoCtrl,
                              decoration: campoDecoration('Correo'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _telefonoCtrl,
                              decoration: campoDecoration('Teléfono'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _direccionCtrl,
                              decoration: campoDecoration('Dirección'),
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: kAzulBorde),
                                minimumSize: const Size(double.infinity, 38),
                              ),
                              onPressed: _cerrarSesion,
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}