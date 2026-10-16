import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/principal_cliente_screen.dart';
import 'package:frontend/services/auth_service.dart';

// Campo de texto personalizado con soporte para ocultar/mostrar contraseña
class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// Botón azul con borde negro
class PrimaryCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A74C0),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(140, 36),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Botón para inicio de sesión con redes sociales (Actualizado con el mismo tamaño y bordes exactos)
class SocialButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        imagePath,
        width: 18,
        height: 18,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.g_mobiledata, color: Colors.white, size: 18),
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A74C0),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(140, 36), // Mismo tamaño mínimo que PrimaryCustomButton
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), // Mismo padding exacto
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Mismos bordes de 8
          side: const BorderSide(color: Colors.black, width: 2), // Mismo borde negro idéntico
        ),
      ),
    );
  }
}

// Contenedor completo para los botones sociales
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Iniciar Sesión con',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            Expanded(child: Divider(color: Colors.white, thickness: 1)),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              label: 'Google',
              imagePath: 'assets/images/google.png',
              onPressed: () async {
                try {
                  AuthService authService = AuthService();
                  await authService.loginConGoogle();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Bienvenido con Google!'), 
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')), 
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}