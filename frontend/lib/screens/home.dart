import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/home_footer_contacts.dart';
import 'package:frontend/widgets/home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _categoriasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasDesdeBD();
  }

  Future<void> _cargarCategoriasDesdeBD() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: ApiConfig.headers,
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        
        List<dynamic> listaTemporal = [];
        
        // Interpreta tanto listas directas como objetos JSON contenedores
        if (decoded is List) {
          listaTemporal = decoded;
        } else if (decoded is Map) {
          if (decoded['data'] is List) {
            listaTemporal = decoded['data'];
          } else if (decoded['categorias'] is List) {
            listaTemporal = decoded['categorias'];
          } else {
            for (var value in decoded.values) {
              if (value is List) {
                listaTemporal = value;
                break;
              }
            }
          }
        }

        setState(() {
          _categoriasList = listaTemporal;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          IconButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );

              if (resultado == true && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrincipalClienteScreen(),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Iniciar Sesión',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        categorias: _categoriasList,
        isLoading: _isLoading,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const HomeHeaderBanner(),
            const SizedBox(height: 40),

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
                  Icon(Icons.local_shipping_rounded, color: Color(0xFF00A8FF), size: 22),
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

            // SECCIÓN CENTRAL: Destacados / Beneficios
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}