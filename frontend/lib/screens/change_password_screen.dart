import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmarPassCtrl = TextEditingController();

  bool _ocultarPass = true;
  bool _ocultarConfirmar = true;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _passCtrl.dispose();
    _confirmarPassCtrl.dispose();
    super.dispose();
  }

  void _cambiarContrasena() {
    // TODO: conectar con el endpoint de recuperación (recuperar) del backend.
  }

  Widget _etiqueta(String texto) => Align(
        alignment: Alignment.centerLeft,
        child: Text(texto, style: const TextStyle(color: kTextoClaro)),
      );

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
                        'Cambiar Contraseña',
                        style: TextStyle(
                          color: kTextoClaro,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _etiqueta('Código'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _codigoCtrl,
                        decoration: campoDecoration(''),
                      ),
                      const SizedBox(height: 10),
                      _etiqueta('Contraseña'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _ocultarPass,
                        decoration: campoDecoration(
                          '',
                          suffixIcon: IconButton(
                            icon: Icon(_ocultarPass
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _ocultarPass = !_ocultarPass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _etiqueta('Confirmar contraseña'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmarPassCtrl,
                        obscureText: _ocultarConfirmar,
                        decoration: campoDecoration(
                          '',
                          suffixIcon: IconButton(
                            icon: Icon(_ocultarConfirmar
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _ocultarConfirmar = !_ocultarConfirmar),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: botonPrincipalStyle(),
                        onPressed: _cambiarContrasena,
                        child: const Text('Cambiar contraseña'),
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