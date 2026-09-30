import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmarPassCtrl = TextEditingController();

  bool _ocultarPass = true;
  bool _ocultarConfirmar = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmarPassCtrl.dispose();
    super.dispose();
  }

  void _crearCuenta() {
    // TODO: conectar con el endpoint de registro (auth) del backend.
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt_outlined, color: kFondoOscuro),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: tarjetaDecoration(),
                  child: Column(
                    children: [
                      const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: kTextoClaro,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nombreCtrl,
                        decoration: campoDecoration('Nombre'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: campoDecoration('Correo'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _direccionCtrl,
                        decoration: campoDecoration('Dirección de residencia'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: campoDecoration('Teléfono'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _ocultarPass,
                        decoration: campoDecoration(
                          'Contraseña',
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
                      TextField(
                        controller: _confirmarPassCtrl,
                        obscureText: _ocultarConfirmar,
                        decoration: campoDecoration(
                          'Confirmar contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(_ocultarConfirmar
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _ocultarConfirmar = !_ocultarConfirmar),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: botonPrincipalStyle(),
                        onPressed: _crearCuenta,
                        child: const Text('Crear Cuenta'),
                      ),
                      const SizedBox(height: 12),
                      const Text('¿Ya tienes una cuenta?',
                          style: TextStyle(color: kTextoClaro)),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: kAzulBorde),
                          minimumSize: const Size(double.infinity, 38),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Inicia sesión'),
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