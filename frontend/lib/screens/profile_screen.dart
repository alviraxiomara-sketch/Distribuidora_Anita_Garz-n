import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:frontend/components/chat_distribuidora_modal.dart';
import 'package:frontend/widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _fondo = Color(0xFF031A2E);
  static const _panel = Color(0xFF084B75);

  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();

  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  img_picker.XFile? _foto;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    try {
      final imagen = await _picker.pickImage(
        source: img_picker.ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (imagen != null) setState(() => _foto = imagen);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la galería')),
      );
    }
  }

  ImageProvider? get _fotoProvider {
    if (_foto == null) return null;
    return kIsWeb
        ? NetworkImage(_foto!.path)
        : FileImage(File(_foto!.path)) as ImageProvider;
  }

  void _abrirChatDistribuidora() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatDistribuidoraModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: const CustomAppBar(currentScreen: 'profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _elegirFoto,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF00A8FF), width: 3),
                  image: _fotoProvider == null
                      ? null
                      : DecorationImage(image: _fotoProvider!, fit: BoxFit.cover),
                ),
                child: _fotoProvider == null
                    ? const Icon(Icons.photo_camera, size: 52, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Perfil',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Times New Roman', 'serif'],
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00A8FF), width: 2),
              ),
              child: Column(
                children: [
                  _campo('Nombre', _nombre),
                  _campo('Correo', _correo, tipo: TextInputType.emailAddress),
                  _campo('Teléfono', _telefono, tipo: TextInputType.phone),
                  _campo('Dirección', _direccion),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 116, 192),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(120, 30),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: const BorderSide(color: Color(0xFF00A8FF), width: 2),
                ),
              ),
              child: const Text('Cerrar sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_chat_perfil',
        backgroundColor: const Color.fromARGB(255, 37, 168, 255),
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: _abrirChatDistribuidora,
        child: ClipOval(
          child: Image.asset(
            'assets/images/robot.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _campo(String hint, TextEditingController c, {TextInputType? tipo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.black26),
          ),
        ),
      ),
    );
  }
}
