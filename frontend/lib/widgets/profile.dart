import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class CampoEditable extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType? tipo;
  final VoidCallback onEdit;
  final VoidCallback onChanged;

  const CampoEditable({
    super.key,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.onEdit,
    required this.onChanged,
    this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF084B75)),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final img_picker.XFile? fotoNueva;
  final String? fotoGuardada;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    this.fotoNueva,
    this.fotoGuardada,
    required this.onTap,
  });

  Widget _buildImagen() {
    // 1. Muestra la foto recién seleccionada localmente
    if (fotoNueva != null) {
      return kIsWeb
          ? Image.network(fotoNueva!.path, fit: BoxFit.cover)
          : Image.file(File(fotoNueva!.path), fit: BoxFit.cover);
    }
    // 2. Muestra la foto guardada en la BD (Base64 o URL)
    if (fotoGuardada != null && fotoGuardada!.isNotEmpty) {
      if (fotoGuardada!.startsWith('http')) {
        return Image.network(fotoGuardada!, fit: BoxFit.cover);
      } else {
        try {
          return Image.memory(base64Decode(fotoGuardada!), fit: BoxFit.cover);
        } catch (_) {}
      }
    }
    // 3. Icono por defecto si no hay foto
    return Container(
      color: Colors.white,
      child: const Icon(Icons.person, size: 55, color: Color(0xFF031A2E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00A8FF), width: 3),
            ),
            child: ClipOval(child: _buildImagen()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00A8FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class BotonGuardar extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonGuardar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save, size: 18),
        label: const Text('Guardar cambios'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A8FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class ChatFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ChatFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab_chat_perfil',
      backgroundColor: const Color(0xFF25A8FF),
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: ClipOval(
        child: Image.asset(
          'assets/images/robot.jpg',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy, color: Colors.white),
        ),
      ),
    );
  }
}