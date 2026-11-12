import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ayuda', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(Icons.inventory_2_outlined, '¿Cómo agrego un producto?',
              'Menú > Agregar Producto, llena los datos y guarda.'),
          _item(Icons.filter_list, '¿Cómo filtro por categoría?',
              'En Inventario, toca Cervezas, Licores, Gaseosas, etc. Tócala otra vez para quitar el filtro.'),
          _item(Icons.warning_amber_rounded, '¿Qué es stock bajo?',
              'Productos cuya cantidad es menor al mínimo configurado.'),
          _item(Icons.notifications_none_rounded, '¿Para qué sirven las notificaciones?',
              'Avisan de pedidos nuevos y alertas de stock.'),
          _item(Icons.bar_chart_rounded, '¿Dónde veo mis ventas?',
              'Menú > Ventas: reportes diarios y mensuales.'),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String titulo, String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00A8FF).withOpacity(0.6)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00A8FF)),
        title: Text(
          titulo,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          texto,
          style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
        ),
      ),
    );
  }
}