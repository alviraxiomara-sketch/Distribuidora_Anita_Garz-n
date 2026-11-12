import 'package:flutter/material.dart';

class TarjetaNotificacionAdmin extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback onEliminar;
  final Function(String url) onVerComprobante;
  final Future<bool> Function(String estado) onCambiarEstado;

  const TarjetaNotificacionAdmin({
    super.key,
    required this.notificacion,
    required this.onEliminar,
    required this.onVerComprobante,
    required this.onCambiarEstado,
  });

  @override
  State<TarjetaNotificacionAdmin> createState() => _TarjetaNotificacionAdminState();
}

class _TarjetaNotificacionAdminState extends State<TarjetaNotificacionAdmin> {
  bool _accionRealizada = false;
  String? _estadoSeleccionado;
  bool _procesando = false;

  int? _obtenerIdPedido() {
    if (widget.notificacion['id_pedido'] != null) {
      return int.tryParse(widget.notificacion['id_pedido'].toString());
    }
    try {
      // Busca el #ID tanto en el título como en el mensaje
      final textoCompleto = '${widget.notificacion['titulo'] ?? ''} ${widget.notificacion['mensaje'] ?? ''}';
      final match = RegExp(r'#(\d+)').firstMatch(textoCompleto);
      return match != null ? int.parse(match.group(1)!) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _manejarAccion(String nuevoEstado) async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final exito = await widget.onCambiarEstado(nuevoEstado);

    if (mounted) {
      setState(() {
        _procesando = false;
        if (exito) {
          _accionRealizada = true;
          _estadoSeleccionado = nuevoEstado;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = widget.notificacion['titulo'] ?? 'Nuevo Pedido';
    final String mensaje = widget.notificacion['mensaje'] ?? '';
    // Lee 'comprobantes' (plural, como está en Supabase) o 'comprobante' por respaldo
    final String? comprobanteUrl = (widget.notificacion['comprobantes'] ?? widget.notificacion['comprobante'])?.toString();
    final int? idPedido = _obtenerIdPedido();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón de eliminar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF031A2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onEliminar,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Detalle del pedido
          Text(
            mensaje,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Imagen del comprobante desplegada a lo ancho (como en tu captura de referencia)
          if (comprobanteUrl != null && comprobanteUrl.trim().isNotEmpty && comprobanteUrl != 'null') ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => widget.onVerComprobante(comprobanteUrl),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      comprobanteUrl,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        width: double.infinity,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('No se pudo cargar el comprobante', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],

          // Botones de Rechazar y Aceptar
          if (idPedido != null) ...[
            const SizedBox(height: 16),
            if (!_accionRealizada)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _procesando ? null : () => _manejarAccion('RECHAZADO'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(color: Color(0xFF3F3D56), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _procesando ? null : () => _manejarAccion('APROBADO'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFF3EDF7),
                        foregroundColor: const Color(0xFF3F3D56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _estadoSeleccionado == 'APROBADO'
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _estadoSeleccionado == 'APROBADO'
                      ? '✓ Pedido aprobado y notificado al cliente'
                      : '✗ Pedido rechazado y notificado al cliente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _estadoSeleccionado == 'APROBADO' ? Colors.green[800] : Colors.red[800],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}