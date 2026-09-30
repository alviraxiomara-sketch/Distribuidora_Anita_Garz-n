import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/boton_principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nombreController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _correoController = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  InputDecoration _decoracionCampo(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.inputFill,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Sesión', style: AppTextStyles.titulo),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary,
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_drink,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Iniciar Sesión', style: AppTextStyles.titulo),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nombreController,
                    style: const TextStyle(color: AppColors.textLight),
                    decoration: _decoracionCampo('Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contrasenaController,
                    obscureText: !_mostrarContrasena,
                    style: const TextStyle(color: AppColors.textLight),
                    decoration: _decoracionCampo(
                      'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarContrasena
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(
                          () => _mostrarContrasena = !_mostrarContrasena,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _correoController,
                    style: const TextStyle(color: AppColors.textLight),
                    decoration: _decoracionCampo('Correo'),
                  ),
                  const SizedBox(height: 20),
                  BotonPrincipal(texto: 'Iniciar Sesión', onPressed: () {}),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidaste tu Contraseña?',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider(color: AppColors.textMuted)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Iniciar Sesión con',
                    style: AppTextStyles.subtitulo,
                  ),
                ),
                Expanded(child: Divider(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BotonPrincipal(
                    texto: 'Facebook',
                    color: AppColors.facebookBlue,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BotonPrincipal(
                    texto: 'Google',
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '¿No tienes cuenta aún?',
              style: AppTextStyles.subtitulo,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 180,
              child: BotonPrincipal(texto: 'Crea tu cuenta', onPressed: () {}),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
