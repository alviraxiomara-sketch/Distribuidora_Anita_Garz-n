import 'package:flutter/material.dart';

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

class NotificacionItemCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback onDelete;
  final Function(String nuevoEstado)? onCambiarEstado; // <--- Parámetro obligatorio agregado

  const NotificacionItemCard({
    super.key,
    required this.notificacion,
    required this.onDelete,
    this.onCambiarEstado,
  });

  // Visor de imagen ampliada con botón "X"
  void _mostrarImagenAmpliada(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'No se pudo cargar la imagen',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = notificacion['titulo'] ?? 'Notificación';
    final String mensaje = notificacion['mensaje'] ?? 'Sin mensaje';
    final String? imagenUrl = notificacion['imagen_url'];
    
    // Detectar si es un mensaje de nuevo pedido para mostrar botones de admin
    final bool esAdminPedido = mensaje.contains('Nuevo pedido') && onCambiarEstado != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Miniatura del comprobante (si viene incluida)
              if (imagenUrl != null && imagenUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => _mostrarImagenAmpliada(context, imagenUrl),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.receipt, size: 30),
                      ),
                    ),
                  ),
                ),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Color(0xFF031A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mensaje,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón Borrar Notificación
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54, size: 20),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          // Botones de Aprobar y Rechazar para el Admin
          if (esAdminPedido) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => onCambiarEstado!('APROBADO'),
                  icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  label: const Text('Aprobar', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => onCambiarEstado!('RECHAZADO'),
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                  label: const Text('Rechazar', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}