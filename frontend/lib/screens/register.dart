import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:frontend/screens/login.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre = TextEditingController(), _correo = TextEditingController();
  final _direccion = TextEditingController(), _telefono = TextEditingController();
  final _password = TextEditingController(), _confirmPassword = TextEditingController();

  bool _ocultarPass = true, _ocultarConfirmPass = true, _cargando = false;
  final AuthService _authService = AuthService();
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  img_picker.XFile? _foto;

  @override
  void dispose() {
    _nombre.dispose(); _correo.dispose(); _direccion.dispose();
    _telefono.dispose(); _password.dispose(); _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    try {
      final img = await _picker.pickImage(source: img_picker.ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 35);
      if (img != null) setState(() => _foto = img);
    } catch (_) {
      _msg('No se pudo abrir la galería', Colors.orange);
    }
  }

  void _msg(String t, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t), backgroundColor: c));

  Future<void> _handleRegister() async {
    if (_nombre.text.isEmpty || _correo.text.isEmpty || _direccion.text.isEmpty || _telefono.text.isEmpty || _password.text.isEmpty) {
      return _msg('Por favor, completa todos los campos', Colors.orange);
    }
    if (_password.text != _confirmPassword.text) return _msg('Las contraseñas no coinciden', Colors.orange);
    if (_password.text.length < 6) return _msg('La contraseña debe tener al menos 6 caracteres', Colors.orange);

    setState(() => _cargando = true);
    try {
      String? fotoB64;
      if (_foto != null) fotoB64 = base64Encode(await _foto!.readAsBytes());

      final res = await _authService.registrar(
        nombre: _nombre.text.trim(), correo: _correo.text.trim(),
        direccion: _direccion.text.trim(), telefono: _telefono.text.trim(),
        password: _password.text.trim(), fotoBase64: fotoB64,
      );

      if (!mounted) return;
      _msg(res['mensaje'] ?? '¡Cuenta creada con éxito!', Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      _msg(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _elegirFoto,
                child: Container(
                  width: 85, height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white,
                    border: Border.all(color: const Color(0xFF00A8FF), width: 3),
                    image: _foto == null ? null : DecorationImage(image: kIsWeb ? NetworkImage(_foto!.path) : FileImage(File(_foto!.path)) as ImageProvider, fit: BoxFit.cover),
                  ),
                  child: _foto == null ? const Icon(Icons.photo_camera, size: 40, color: Colors.black) : null,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF063B5D), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Registrarse', style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    AuthTextField(hint: 'Nombre', controller: _nombre),
                    AuthTextField(hint: 'Correo', controller: _correo),
                    AuthTextField(hint: 'Dirección de residencia', controller: _direccion),
                    AuthTextField(hint: 'Telefono', controller: _telefono),
                    AuthTextField(hint: 'Contraseña', controller: _password, isPassword: true, obscureText: _ocultarPass, onToggleVisibility: () => setState(() => _ocultarPass = !_ocultarPass)),
                    AuthTextField(hint: 'Confirmar contraseña', controller: _confirmPassword, isPassword: true, obscureText: _ocultarConfirmPass, onToggleVisibility: () => setState(() => _ocultarConfirmPass = !_ocultarConfirmPass)),
                    const SizedBox(height: 10),
                    _cargando ? const CircularProgressIndicator(color: Color(0xFF00A8FF)) : PrimaryCustomButton(text: 'Crear Cuenta', onPressed: _handleRegister),
                    const SizedBox(height: 10),
                    const Text('¿Ya tienes una cuenta?', style: TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 10),
                    PrimaryCustomButton(text: 'inicia sesion', onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}