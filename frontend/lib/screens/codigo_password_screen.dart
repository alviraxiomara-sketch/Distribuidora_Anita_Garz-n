import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/recover_service.dart';
import 'package:frontend/widgets/login_widgets.dart';

class CodigoPasswordScreen extends StatefulWidget {
  final String correoUsuario;
  const CodigoPasswordScreen({super.key, required this.correoUsuario});

  @override
  State<CodigoPasswordScreen> createState() => _CodigoPasswordScreenState();
}

class _CodigoPasswordScreenState extends State<CodigoPasswordScreen> {
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;
  bool _cargando = false;
  final RecoverService _recoverService = RecoverService();

  @override
  void dispose() {
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _cambiarContrasena() async {
    final codigo = _codigoController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (codigo.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _mostrarMensaje('Por favor completa todos los campos', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _mostrarMensaje('Las contraseñas no coinciden', Colors.red);
      return;
    }

    setState(() => _cargando = true);

    try {
      // Conecta con el backend para actualizar la contraseña en la base de datos
      await _recoverService.cambiarContrasenaConCodigo(
        correo: widget.correoUsuario,
        codigo: codigo,
        nuevaPassword: password,
      );

      if (!mounted) return;
      _mostrarMensaje('¡Contraseña actualizada con éxito!', Colors.green);

      // Regresa al login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFF00A8FF),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink,
                        color: Color(0xFF031A2E),
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF063B5D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00A8FF),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Codigo',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    AuthTextField(hint: '', controller: _codigoController),
                    const SizedBox(height: 10),
                    const Text(
                      'Contraseña',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    AuthTextField(
                      hint: '',
                      controller: _passwordController,
                      isPassword: true,
                      obscureText: _ocultarPassword,
                      onToggleVisibility: () => setState(
                        () => _ocultarPassword = !_ocultarPassword,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Confirmar contraseña',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    AuthTextField(
                      hint: '',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      obscureText: _ocultarConfirmPassword,
                      onToggleVisibility: () => setState(
                        () => _ocultarConfirmPassword = !_ocultarConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: _cargando
                          ? const CircularProgressIndicator(
                              color: Color(0xFF00A8FF),
                            )
                          : PrimaryCustomButton(
                              text: 'Cambiar contraseña',
                              onPressed: _cambiarContrasena,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}