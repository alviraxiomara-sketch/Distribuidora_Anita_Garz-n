import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/recover_password_screen.dart.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/widgets/auth_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  final _correoController = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _passwordController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _irA(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                            const SizedBox(height: 18),
                            AuthTextField(hint: 'Nombre', controller: _nombreController),
                            AuthTextField(
                              hint: 'Contraseña',
                              controller: _passwordController,
                              isPassword: true,
                              obscureText: _ocultarPassword,
                              onToggleVisibility: () => setState(() => _ocultarPassword = !_ocultarPassword),
                            ),
                            AuthTextField(hint: 'Correo', controller: _correoController),
                            const SizedBox(height: 10),
                            PrimaryCustomButton(
                              text: 'Iniciar Sesión',
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _irA(const RecoverPasswordScreen()),
                              child: const Text(
                                '¿Olvidaste tu Contraseña?',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Iniciar Sesión con', style: TextStyle(color: Colors.white, fontSize: 15)),
                        ),
                        Expanded(child: Divider(color: Colors.white, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialButton(label: 'Facebook', icon: Icons.facebook, iconColor: const Color.fromARGB(255, 10, 28, 43), onPressed: () {}),
                        const SizedBox(width: 20),
                        SocialButton(label: 'Google', icon: Icons.g_mobiledata, iconColor: const Color.fromARGB(255, 146, 12, 2), onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: const Color(0xFF084B75),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta aun?', style: TextStyle(color: Colors.white, fontSize: 17)),
                            const SizedBox(height: 5),
                            PrimaryCustomButton(
                              text: 'Crea una cuenta',
                              onPressed: () => _irA(const RegisterScreen()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}