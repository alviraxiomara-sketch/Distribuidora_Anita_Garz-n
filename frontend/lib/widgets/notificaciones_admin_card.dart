import 'package:flutter/material.dart';

class NotificacionAdmin extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final Function(int idPedido, String nuevoEstado) onCambiarEstado;

  const NotificacionAdmin({
    super.key,
    required this.notificacion,
    required this.onCambiarEstado,
  });

  @override
  State<NotificacionAdmin> createState() => _NotificacionAdminState();
}

class _NotificacionAdminState extends State<NotificacionAdmin> {
  bool _accionRealizada = false;
  String? _estadoSeleccionado;

  void _mostrarComprobanteAmpliado(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Error al cargar la imagen', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = widget.notificacion['titulo'] ?? 'Nueva Notificación';
    final String mensaje = widget.notificacion['mensaje'] ?? '';
    final String? comprobanteUrl = widget.notificacion['comprobante'];
    final int? idPedido = widget.notificacion['id_pedido'];

    return Card(
      color: const Color(0xFF063B5D),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00A2E8), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Color(0xFF00A2E8), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            
            // Sección del Comprobante (si existe)
            if (comprobanteUrl != null && comprobanteUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _mostrarComprobanteAmpliado(context, comprobanteUrl),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          comprobanteUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black38,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Toca para ampliar comprobante',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Botones de Acción o Mensaje de Confirmación
            if (idPedido != null) ...[
              const SizedBox(height: 14),
              if (!_accionRealizada)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _accionRealizada = true;
                            _estadoSeleccionado = 'APROBADO';
                          });
                          widget.onCambiarEstado(idPedido, 'APROBADO');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white, size: 18),
                        label: const Text('Aprobar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _accionRealizada = true;
                            _estadoSeleccionado = 'RECHAZADO';
                          });
                          widget.onCambiarEstado(idPedido, 'RECHAZADO');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        label: const Text('Rechazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _estadoSeleccionado == 'APROBADO' 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _estadoSeleccionado == 'APROBADO' ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _estadoSeleccionado == 'APROBADO' ? Icons.check_circle : Icons.cancel,
                        color: _estadoSeleccionado == 'APROBADO' ? Colors.greenAccent : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _estadoSeleccionado == 'APROBADO' ? '✓ Pedido Aprobado' : '✗ Pedido Rechazado',
                        style: TextStyle(
                          color: _estadoSeleccionado == 'APROBADO' ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}