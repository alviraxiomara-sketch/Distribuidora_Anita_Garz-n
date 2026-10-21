import 'package:flutter/material.dart';
import 'package:frontend/screens/hit_products_screen.dart';

class HitProductsScreen extends StatelessWidget {
  const HitProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Jugos Hit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // Aquí puedes agregar los productos específicos de Hit (ej: Hit de Mora, Hit de Mango, etc.)
          ListTile(
            title: Text('Hit de Mango 1L', style: TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: Text('Caja x 12 unidades', style: TextStyle(color: Colors.white70)),
          ),
          Divider(color: Colors.white24),
          ListTile(
            title: Text('Hit de Mora 1L', style: TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: Text('Caja x 12 unidades', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}