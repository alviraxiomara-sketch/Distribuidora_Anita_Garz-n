import 'package:flutter/material.dart';

/// Colores unificados del chat con la paleta oscura de la aplicación.
class ChatColors {
  static const fondo = Color(0xFF031A2E); // Coincide con el fondo general de tus pantallas
  static const panel = Color(0xFF063B5D); // Coincide con el color de las barras y tarjetas
  static const borde = Color(0xFF00A8FF); // Coincide con el azul brillante de bordes
  static const celeste = Color(0xFF00A8FF);
  static const burbujaBot = Color(0xFF063B5D);
  static const burbujaUsuario = Color(0xFF0A4D73);
}

/// Avatar circular del asistente xiomy (usa assets/images/asistente.png).
class AsistenteAvatar extends StatelessWidget {
  final double radio;
  const AsistenteAvatar({super.key, this.radio = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radio * 2,
      height: radio * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(0, 168, 255, 1),
          width: radio >= 24 ? 3 : 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/asistente.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.smart_toy, size: radio, color: ChatColors.fondo),
        ),
      ),
    );
  }
}