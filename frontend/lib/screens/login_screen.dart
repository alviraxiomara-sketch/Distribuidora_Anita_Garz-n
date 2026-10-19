import 'package:flutter/material.dart';
import 'package:frontend/screens/principal_cliente_screen.dart';
import 'package:frontend/screens/recuperar_password_screen.dart';
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
  bool _ocultarPassword = true, _cargando = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _irA(Widget pantalla) => Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  void _msg(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
  }

  Future<void> _handleLogin() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) return _msg('Ingresa correo y contraseña', Colors.orange);

    setState(() => _cargando = true);
    try {
      final respuesta = await _authService.login(correo: correo, password: password);
      _msg(respuesta['mensaje'] ?? '¡Bienvenido!', Colors.green);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
        (route) => false,
      );
    } catch (e) {
      _msg(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await _authService.loginConGoogle();
      _msg(respuesta['mensaje'] ?? '¡Bienvenido con Google!', Colors.blue);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
        (route) => false,
      );
    } catch (e) {
      final mensaje = e.toString().replaceAll('Exception: ', '');
      if (!mensaje.contains('cancelado')) _msg(mensaje, Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 22, 39),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Logo superior
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFF00A8FF),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.local_drink, color: Colors.white, size: 48),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Tarjeta Iniciar Sesión
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
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(hint: 'Correo Electrónico', controller: _correoController),
                          AuthTextField(
                            hint: 'Contraseña',
                            controller: _passwordController,
                            isPassword: true,
                            obscureText: _ocultarPassword,
                            onToggleVisibility: () => setState(() => _ocultarPassword = !_ocultarPassword),
                          ),
                          const SizedBox(height: 16),
                          _cargando
                              ? const CircularProgressIndicator(color: Color(0xFF00A8FF))
                              : PrimaryCustomButton(text: 'Iniciar Sesión', onPressed: _handleLogin),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => _irA(const RecoverPasswordScreen()),
                            child: const Text('¿Olvidaste tu Contraseña?', style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Separador y Botón de Google
                    SocialLoginButtons(onGooglePressed: _handleGoogleLogin),

                    const SizedBox(height: 12),

                    // 4. Tarjeta Inferior de Registro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF063B5D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00A8FF).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text('¿No tienes cuenta aún?', style: TextStyle(color: Colors.white, fontSize: 15)),
                          const SizedBox(height: 8),
                          PrimaryCustomButton(text: 'Crea una cuenta', onPressed: () => _irA(const RegisterScreen())),
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