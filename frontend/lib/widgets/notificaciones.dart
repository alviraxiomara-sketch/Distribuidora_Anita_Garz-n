import 'package:flutter/material.dart';

class BadgePedidos extends StatelessWidget {
  const BadgePedidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Gestión de Pedidos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class NotificacionItemCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback onDelete;
  final Function(String nuevoEstado)? onCambiarEstado;

  const NotificacionItemCard({
    super.key,
    required this.notificacion,
    required this.onDelete,
    this.onCambiarEstado,
  });

  // Visor de imagen ampliada del comprobante con botón de cierre "X"
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
                    'No se pudo cargar la imagen del comprobante',
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
    final String titulo = notificacion['titulo'] ?? 'Nuevo Pedido';
    final String mensaje = notificacion['mensaje'] ?? 'Sin detalles del pedido';
    
    // Leemos directamente de la columna 'comprobante' que creamos en la base de datos
    final String? comprobanteUrl = notificacion['comprobante'] ?? 
                                   notificacion['imagen_url'] ?? 
                                   notificacion['screenshot'];
    
    final bool esAdminPedido = mensaje.toLowerCase().contains('pedido') && onCambiarEstado != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Miniatura del comprobante de Nequi (si existe en la BD)
                if (comprobanteUrl != null && comprobanteUrl.toString().trim().isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _mostrarImagenAmpliada(context, comprobanteUrl.toString()),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              comprobanteUrl.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.receipt_long, size: 30, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.zoom_in, color: Colors.white, size: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Textos de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // <--- Corregido aquí
                        children: [
                          Expanded(
                            child: Text(
                              titulo,
                              style: TextStyle(
                                color: Color(0xFF031A2E),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mensaje,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Botones de Aprobar y Rechazar para el Admin
            if (esAdminPedido) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE0E0E0), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onCambiarEstado!('RECHAZADO'),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                    label: const Text('Rechazar', style: TextStyle(color: Colors.red, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => onCambiarEstado!('APROBADO'),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                    label: const Text('Aprobar', style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}