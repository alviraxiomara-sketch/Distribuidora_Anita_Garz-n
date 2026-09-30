import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() =>
      _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _correoCtrl = TextEditingController();

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  void _enviarCorreo() {
    // TODO: conectar con el endpoint de recuperación (recuperar) del backend.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondoOscuro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, color: kFondoOscuro),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: tarjetaDecoration(),
                  child: Column(
                    children: [
                      const Text(
                        'Recuperar Contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextoClaro,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Correo', style: TextStyle(color: kTextoClaro)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: campoDecoration(''),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: botonPrincipalStyle(),
                        onPressed: _enviarCorreo,
                        child: const Text('Enviar Correo'),
                      ),
                    ],
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