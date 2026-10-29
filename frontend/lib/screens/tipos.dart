import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/importadas_screen.dart'; // Asegúrate de tener esta pantalla creada
import 'package:frontend/screens/nacionales_screen.dart'; // Asegúrate de tener esta pantalla creada
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';

class TiposScreen extends StatefulWidget {
  final String categoria;

  const TiposScreen({super.key, required this.categoria});

  @override
  State<TiposScreen> createState() => _TiposScreenState();
}

class _TiposScreenState extends State<TiposScreen> {
  bool _cargando = true;
  List<dynamic> _categoriasList = [];
  
  final List<String> tipos = ['Importadas', 'Nacionales'];

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
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // Función para verificar sesión al presionar la casa (Home)
  Future<void> _verificarSesionYRedirigirHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  // Función para verificar sesión al presionar el usuario (Profile / Login)
  Future<void> _verificarSesionYRedirigirPerfil(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E), // Color exacto de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D), // Color exacto de barra superior
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón de Inicio (Home) con validación
          IconButton(
            onPressed: () => _verificarSesionYRedirigirHome(context),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
          ),
          
          // 🚫 EL CARRITO HA SIDO REMOVIDO DE ESTA PANTALLA A PROPÓSITO
          
          // Botón de Usuario / Perfil con validación de sesión
          IconButton(
            onPressed: () => _verificarSesionYRedirigirPerfil(context),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(categorias: _categoriasList, isLoading: _cargando),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Tipos',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00A8FF).withOpacity(0.5), 
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF063B5D).withOpacity(0.3),
              ),
              child: Column(
                children: tipos.map((tipo) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        // Navegación según el tipo seleccionado
                        if (tipo == 'Importadas') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ImportadasScreen()),
                          );
                        } else if (tipo == 'Nacionales') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NacionalesScreen()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00A8FF).withOpacity(0.6), 
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF063B5D),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tipo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF00A8FF),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}