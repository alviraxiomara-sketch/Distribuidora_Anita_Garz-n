import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/login_widgets.dart';

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
  bool _cargando = false;

  final AuthService _authService = AuthService();
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
      _mostrarMensaje('No se pudo abrir la galería', Colors.orange);
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

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _handleRegister() async {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono = _telefonoController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones
    if (nombre.isEmpty ||
        correo.isEmpty ||
        direccion.isEmpty ||
        telefono.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _mostrarMensaje('Por favor, completa todos los campos', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _mostrarMensaje('Las contraseñas no coinciden', Colors.orange);
      return;
    }

    if (password.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres', Colors.orange);
      return;
    }

    setState(() => _cargando = true);

    try {
      final respuesta = await _authService.registrar(
        nombre: nombre,
        correo: correo,
        direccion: direccion,
        telefono: telefono,
        password: password,
      );

      if (!mounted) return;

      _mostrarMensaje(
        respuesta['mensaje'] ?? '¡Cuenta creada con éxito!',
        Colors.green,
      );

      _irAIniciaSesion();
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
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
                const SizedBox(height: 47),
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
                        _cargando
                            ? const CircularProgressIndicator(color: Color(0xFF00A8FF))
                            : PrimaryCustomButton(text: 'Crear Cuenta', onPressed: _handleRegister),
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