import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/auth_screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;

  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  img_picker.XFile? _foto;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _irAIniciaSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter, // Alinea el contenido hacia arriba
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8), // Padding superior mínimo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10), // Pequeño margen superior
                GestureDetector(
                  onTap: _elegirFoto,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF00A8FF), width: 3),
                      image: _fotoProvider == null
                          ? null
                          : DecorationImage(image: _fotoProvider!, fit: BoxFit.cover),
                    ),
                    child: _fotoProvider == null
                        ? const Icon(Icons.photo_camera, size: 40, color: Colors.black)
                        : null,
                  ),
                ),
                const SizedBox(height: 47), // Se redujo el espacio para subir la tarjeta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF063B5D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 17),
                        AuthTextField(hint: 'Nombre', controller: _nombreController),
                        AuthTextField(hint: 'Correo', controller: _correoController),
                        AuthTextField(hint: 'Dirección de residencia', controller: _direccionController),
                        AuthTextField(hint: 'Telefono', controller: _telefonoController),
                        AuthTextField(
                          hint: 'Contraseña',
                          controller: _passwordController,
                          isPassword: true,
                          obscureText: _ocultarPassword,
                          onToggleVisibility: () => setState(() => _ocultarPassword = !_ocultarPassword),
                        ),
                        AuthTextField(
                          hint: 'Confirmar contraseña',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          obscureText: _ocultarConfirmPassword,
                          onToggleVisibility: () => setState(() => _ocultarConfirmPassword = !_ocultarConfirmPassword),
                        ),
                        const SizedBox(height: 10),
                        PrimaryCustomButton(text: 'Crear Cuenta', onPressed: _irAIniciaSesion),
                        const SizedBox(height: 10),
                        const Text(
                          '¿Ya tienes una cuenta?',
                          style: TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 17),
                        ),
                        const SizedBox(height: 10),
                        PrimaryCustomButton(text: 'inicia sesion', onPressed: _irAIniciaSesion),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}