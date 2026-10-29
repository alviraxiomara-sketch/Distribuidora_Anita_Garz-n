import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/cart.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/cerveza_opcion_card.dart';

class CervezasScreen extends StatefulWidget {
  const CervezasScreen({super.key});

  @override
  State<CervezasScreen> createState() => _CervezasScreenState();
}

class _CervezasScreenState extends State<CervezasScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

      final url = Uri.parse('${ApiConfig.baseUrl}/categorias');
      print('Haciendo petición a: $url');

      final res = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Código de respuesta: ${res.statusCode}');
      print('Cuerpo de respuesta: ${res.body}');

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        setState(() {
          _categoriasList = decoded is List ? decoded : [];
        });
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      drawer: AppDrawer(categorias: _categoriasList),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        leadingWidth: 130,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrincipalClienteScreen(),
                ),
                (_) => false,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 24,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            const Text(
              'Tipos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF384E5E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00A8FF), width: 2),
              ),
              child: Column(
                children: [
                  CervezaOpcionCard(titulo: 'Importadas', onTap: () {}),
                  CervezaOpcionCard(titulo: 'Nacionales', onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
