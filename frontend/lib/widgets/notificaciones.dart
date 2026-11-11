import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/notificaciones_admin.dart';
import 'package:frontend/screens/notificaciones_cliente.dart';
import 'package:frontend/services/api_config.dart';

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

class NotificacionItemCard extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final VoidCallback onDelete;
  final Function(String nuevoEstado)? onCambiarEstado;

  const NotificacionItemCard({
    super.key,
    required this.notificacion,
    required this.onDelete,
    this.onCambiarEstado,
  });

  @override
  State<NotificacionItemCard> createState() => _NotificacionItemCardState();
}

class _NotificacionItemCardState extends State<NotificacionItemCard> {
  bool _accionRealizada = false;
  String? _estadoSeleccionado;

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
    final String titulo = widget.notificacion['titulo'] ?? 'Nuevo Pedido';
    final String mensaje = widget.notificacion['mensaje'] ?? 'Sin detalles';
    
    final String? comprobanteUrl = widget.notificacion['comprobante'] ?? 
                                   widget.notificacion['imagen_url'] ??
                                   widget.notificacion['comprobante_url'];
    
    final bool esAdminPedido = widget.onCambiarEstado != null;

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
                if (comprobanteUrl != null && comprobanteUrl.toString().trim().isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _mostrarImagenAmpliada(context, comprobanteUrl.toString()),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              titulo,
                              style: const TextStyle(
                                color: Color(0xFF031A2E),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: widget.onDelete,
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

            if (esAdminPedido && !_accionRealizada) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE0E0E0), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _accionRealizada = true;
                        _estadoSeleccionado = 'RECHAZADO';
                      });
                      widget.onCambiarEstado!('RECHAZADO');
                    },
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
                    onPressed: () {
                      setState(() {
                        _accionRealizada = true;
                        _estadoSeleccionado = 'APROBADO';
                      });
                      widget.onCambiarEstado!('APROBADO');
                    },
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
            ] else if (_accionRealizada) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _estadoSeleccionado == 'APROBADO' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _estadoSeleccionado == 'APROBADO' 
                      ? '✓ Pedido aprobado y notificado al cliente' 
                      : '✗ Pedido rechazado y notificado al cliente',
                  style: TextStyle(
                    color: _estadoSeleccionado == 'APROBADO' ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================
// CAMPANA DE NOTIFICACIONES CON BADGE DINÁMICO
// ==========================
class NotificationBadgeIcon extends StatefulWidget {
  final bool esAdmin; // Parámetro para saber si debe abrir la vista de administrador

  const NotificationBadgeIcon({super.key, this.esAdmin = false});

  @override
  State<NotificationBadgeIcon> createState() => _NotificationBadgeIconState();
}

class _NotificationBadgeIconState extends State<NotificationBadgeIcon> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _obtenerNotificacionesNoLeidas();
  }

  Future<void> _obtenerNotificacionesNoLeidas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        List<dynamic> lista = [];

        if (decoded is List) {
          lista = decoded;
        } else if (decoded is Map) {
          lista = decoded['data'] ?? decoded['notificaciones'] ?? [];
        }

        int noLeidas = lista.where((item) {
          final bool leido = item['leido'] ?? item['leida'] ?? false;
          return !leido;
        }).length;

        setState(() {
          _unreadCount = noLeidas;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
          onPressed: () async {
            // Navega a NotificacionesAdmin si esAdmin es true, de lo contrario a NotificacionesScreen (cliente)
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => widget.esAdmin 
                    ? const NotificacionesAdmin() 
                    : const NotificacionesScreen(),
              ),
            );
            _obtenerNotificacionesNoLeidas();
          },
        ),
        if (_unreadCount > 0)
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
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '$_unreadCount',
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