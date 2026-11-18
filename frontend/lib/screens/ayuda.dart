import 'package:flutter/material.dart';
import 'package:frontend/screens/profile.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:frontend/widgets/admin_drawer.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      drawer: const AdminDrawer(), // menú lateral
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ayuda', style: TextStyle(color: Colors.white)),
        actions: [
          // Casita: vuelve a la pantalla principal
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Inicio',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          // Perfil
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
          body: SfPdfViewer.asset(
        'assets/pdf/manual_usuario.pdf',
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el PDF: ${details.description}')),
          );
        },
      ),
    );
  }
}