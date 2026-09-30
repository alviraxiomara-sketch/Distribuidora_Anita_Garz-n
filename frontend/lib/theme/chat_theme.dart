import 'package:flutter/material.dart';

/// Colores del chat (tomados del diseño de Figma; ajusta el hex si hace falta).
class ChatColors {
  static const fondo = Color(0xFF06294B);
  static const panel = Color(0xFF1B4F80);
  static const borde = Color(0xFF2196F3);
  static const celeste = Color(0xFF29B6F6);
  static const burbujaBot = Color.fromARGB(255, 77, 133, 197);
  static const burbujaUsuario = Color.fromARGB(255, 24, 79, 129);
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
          color: ChatColors.celeste,
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
