import 'package:flutter/material.dart';
import 'package:frontend/screens/codigo_password_screen.dart';
import 'package:frontend/services/recover_service.dart';
import 'package:frontend/widgets/login_widgets.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _correoController = TextEditingController();
  final RecoverService _recoverService = RecoverService();
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    final correo = _correoController.text.trim();

    if (correo.isEmpty) {
      _mostrarMensaje('Por favor ingresa tu correo', Colors.orange);
      return;
    }

    setState(() => _cargando = true);

    try {
      // Conecta con tu backend para generar y enviar el código
      await _recoverService.solicitarRecuperacion(correo: correo);

      if (!mounted) return;
      _mostrarMensaje('¡Código enviado a tu correo!', Colors.green);

      // Redirige a la pantalla del código enviando el correo como parámetro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CodigoPasswordScreen(correoUsuario: correo),
        ),
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
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFF00A8FF),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink,
                        color: Color(0xFF031A2E),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
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
                      const Center(
                        child: Text(
                          'Recuperar Contraseña',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Correo',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      AuthTextField(hint: '', controller: _correoController),
                      const SizedBox(height: 16),
                      Center(
                        child: _cargando
                            ? const CircularProgressIndicator(
                                color: Color(0xFF00A8FF),
                              )
                            : PrimaryCustomButton(
                                text: 'Enviar Correo',
                                onPressed: _enviarCorreo,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}