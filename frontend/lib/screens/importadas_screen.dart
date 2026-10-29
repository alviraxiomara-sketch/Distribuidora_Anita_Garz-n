import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/tipos_catalogo.dart';

class ImportadasScreen extends StatefulWidget {
  const ImportadasScreen({super.key});

  @override
  State<ImportadasScreen> createState() => _ImportadasScreenState();
}

class _ImportadasScreenState extends State<ImportadasScreen> {
  bool _cargando = true;
  List<dynamic> _categoriasList = [];
  
  final List<String> _productosImportados = [
    'Corona Extra',
    'Heineken',
    'Stella Artois',
    'Budweiser',
  ];

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
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // 1. Primero el menú hamburguesa
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            // 2. Después la flecha de retroceso
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _verificarSesionYRedirigirHome(context),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
          ),
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
            const Text(
              'Cervezas Importadas',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00A8FF).withOpacity(0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF063B5D).withOpacity(0.3),
                ),
                child: ListView.builder(
                  itemCount: _productosImportados.length,
                  itemBuilder: (context, index) {
                    final producto = _productosImportados[index];
                    return ItemCatalogoCard(
                      titulo: producto,
                      onTap: () {
                        // Acción al presionar
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}