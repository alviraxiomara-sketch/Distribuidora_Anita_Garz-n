import 'package:flutter/material.dart';
import 'package:frontend/screens/principal_cliente_screen.dart';
import 'package:frontend/screens/recover_password_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _cargando = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _irA(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _handleLogin() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mostrarMensaje('Ingresa correo y contraseña', Colors.orange);
      return;
    }

    setState(() => _cargando = true);

    try {
      final respuesta = await _authService.login(correo: correo, password: password);
      if (!mounted) return;

      _mostrarMensaje(respuesta['mensaje'] ?? '¡Bienvenido!', Colors.green);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      backgroundColor: const Color.fromARGB(255, 2, 22, 39),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF00A8FF),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_drink,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF063B5D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            hint: 'Correo Electrónico',
                            controller: _correoController,
                          ),
                          AuthTextField(
                            hint: 'Contraseña',
                            controller: _passwordController,
                            isPassword: true,
                            obscureText: _ocultarPassword,
                            onToggleVisibility: () =>
                                setState(() => _ocultarPassword = !_ocultarPassword),
                          ),
                          const SizedBox(height: 10),
                          _cargando
                              ? const CircularProgressIndicator(color: Color(0xFF00A8FF))
                              : PrimaryCustomButton(
                                  text: 'Iniciar Sesión',
                                  onPressed: _handleLogin,
                                ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _irA(const RecoverPasswordScreen()),
                            child: const Text(
                              '¿Olvidaste tu Contraseña?',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SocialLoginButtons(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF084B75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¿No tienes cuenta aún?',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          PrimaryCustomButton(
                            text: 'Crea una cuenta',
                            onPressed: () => _irA(const RegisterScreen()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}