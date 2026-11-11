import 'package:flutter/material.dart';

class NotificacionItemCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback? onDelete;

  const NotificacionItemCard({
    super.key,
    required this.notificacion,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String mensaje = notificacion['mensaje'] ?? 'Tu notificación';
    final String? imagenUrl = notificacion['imagen_url'];
    final bool destacado = notificacion['destacado'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
        border: destacado ? Border.all(color: const Color(0xFF00A8FF), width: 1.5) : null,
      ),
      child: Row(
        children: [
          // Imagen miniatura del producto con respaldo local/icono
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (imagenUrl != null && imagenUrl.isNotEmpty && imagenUrl.startsWith('http'))
                  ? Image.network(
                      imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_drink_rounded,
                          color: Color(0xFF031A2E),
                          size: 24,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink_rounded,
                        color: Color(0xFF031A2E),
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Texto de la notificación
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Botón de eliminar (Papelera)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54, size: 20),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}