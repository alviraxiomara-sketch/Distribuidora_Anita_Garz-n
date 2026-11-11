import 'package:flutter/material.dart';
import 'package:frontend/screens/notificaciones_admin.dart';
import 'package:frontend/screens/notificaciones_cliente.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final int cantidadNoLeidas;
  final String? rolUsuario;
  final bool? esAdmin;

  const NotificationBadgeIcon({
    super.key,
    this.cantidadNoLeidas = 0,
    this.rolUsuario,
    this.esAdmin,
  });

  @override
  Widget build(BuildContext context) {
    // Determinamos si es admin por el texto o por el booleano
    final bool isAdminReal = esAdmin ?? (rolUsuario?.toLowerCase().contains('admin') ?? false);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => isAdminReal
                    ? const NotificacionesAdminScreen()
                    : const NotificacionesScreen(),
              ),
            );
          },
        ),
        if (cantidadNoLeidas > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$cantidadNoLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}