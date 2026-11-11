import 'package:flutter/material.dart';

class NotificacionClienteCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;

  const NotificacionClienteCard({
    super.key,
    required this.notificacion,
  });

  @override
  Widget build(BuildContext context) {
    final String titulo = notificacion['titulo'] ?? 'Notificación';
    final String mensaje = notificacion['mensaje'] ?? '';
    final bool leida = notificacion['leida'] ?? false;

    return Card(
      color: leida ? const Color(0xFF042840) : const Color(0xFF063B5D),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: leida ? Colors.transparent : const Color(0xFF00A2E8),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: leida ? Colors.white10 : const Color(0xFF00A2E8).withOpacity(0.2),
          child: Icon(
            leida ? Icons.notifications_none : Icons.notifications_active,
            color: leida ? Colors.white54 : const Color(0xFF00A2E8),
          ),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: Colors.white,
            fontWeight: leida ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            mensaje,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
    );
  }
}