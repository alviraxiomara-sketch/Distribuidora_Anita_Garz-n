import 'package:flutter/material.dart';
import '../components/producto_card.dart';
import '../components/chat_distribuidora_modal.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _abrirChatDistribuidora(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatDistribuidoraModal(),
    );
  }

  void _mostrarModalDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Próximamente disponible con toda la información cargada desde el panel administrativo.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 246, 244, 240),
      appBar: AppBar(
        title: const Text(
          'Catálogo de Productos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 191, 40, 93),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          children: [
            ProductoCard(
              onVerMas: () => _mostrarModalDetalle(context),
              onComprar: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de compra disponible próximamente'),
                    backgroundColor: Color(0xFFE91E63),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_chat_menu',
        backgroundColor: const Color.fromRGBO(255, 188, 37, 82),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.support_agent_rounded, size: 26),
        label: const Text(
          'Asesor Anita',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () => _abrirChatDistribuidora(context),
      ),
    );
  }
}