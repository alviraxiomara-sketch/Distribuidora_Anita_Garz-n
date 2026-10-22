import 'package:flutter/material.dart';

/// Widget para la etiqueta/píldora superior "Pedidos"
class BadgePedidos extends StatelessWidget {
  const BadgePedidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF084B75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
      ),
      child: const Text(
        'Pedidos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}

/// Widget para cada elemento individual de la lista de notificaciones
class NotificacionItemCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback onDelete;

  const NotificacionItemCard({
    super.key,
    required this.notificacion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String mensaje = notificacion['mensaje'] ?? 'Sin mensaje';
    final String? imagenUrl = notificacion['imagen_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), // Gris claro según el diseño
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Imagen del producto / notificación
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
              child: imagenUrl != null && imagenUrl.isNotEmpty
                  ? Image.network(
                      imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF031A2E),
                      ),
                    )
                  : Image.asset(
                      'assets/images/logo.png', // Imagen local por defecto
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF031A2E),
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

          // Botón de eliminar notificación
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54, size: 22),
            onPressed: onDelete,
            tooltip: 'Eliminar notificación',
          ),
        ],
      ),
    );
  }
}