import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_config.dart';

class NotificacionesAdmin extends StatefulWidget {
  const NotificacionesAdmin({super.key});

  @override
  State<NotificacionesAdmin> createState() => _NotificacionesAdminState();
}

class _NotificacionesAdminState extends State<NotificacionesAdmin> {
  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
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
        setState(() {
          _notificaciones = decoded is List ? decoded : (decoded['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarComprobanteAmpliado(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.white)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEstadoPedido(Map<String, dynamic> notificacion, String nuevoEstado, StateSetter setStateCard, Function onSuccess) async {
    int? pedidoId = notificacion['id_pedido'];
    if (pedidoId == null) {
      try {
        final regExp = RegExp(r'#(\d+)');
        final match = regExp.firstMatch(notificacion['mensaje'] ?? '');
        if (match != null) pedidoId = int.parse(match.group(1)!);
      } catch (_) {}
    }

    if (pedidoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el ID del pedido'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/pedidos/$pedidoId/estado-notificar'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': nuevoEstado}),
      );

      if (res.statusCode == 200 && mounted) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido #$pedidoId ${nuevoEstado.toLowerCase()} exitosamente y cliente notificado'),
            backgroundColor: nuevoEstado == 'APROBADO' ? Colors.green : Colors.red,
          ),
        );
      } else {
        final decoded = jsonDecode(res.body);
        throw Exception(decoded['error'] ?? 'Error al actualizar');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _eliminarNotificacion(dynamic id, int index) async {
    setState(() => _notificaciones.removeAt(index));
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id/eliminar'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        title: const Text('Gestión de Pedidos (Admin)', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF384E5E).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                    : _notificaciones.isEmpty
                        ? const Center(
                            child: Text('No hay notificaciones de pedidos', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          )
                        : ListView.builder(
                            itemCount: _notificaciones.length,
                            itemBuilder: (context, index) {
                              final noti = _notificaciones[index];
                              final idNoti = noti['id_notificacion'] ?? noti['id'] ?? index;
                              final String titulo = noti['titulo'] ?? 'Nuevo Pedido';
                              final String mensaje = noti['mensaje'] ?? '';
                              final String? comprobanteUrl = noti['comprobante'];
                              final int? idPedido = noti['id_pedido'] ?? (() {
                                try {
                                  final regExp = RegExp(r'#(\d+)');
                                  final match = regExp.firstMatch(mensaje);
                                  return match != null ? int.parse(match.group(1)!) : null;
                                } catch (_) {
                                  return null;
                                }
                              }());

                              bool accionRealizada = false;
                              String? estadoSeleccionado;

                              return StatefulBuilder(
                                builder: (context, setStateCard) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Miniatura del comprobante
                                              if (comprobanteUrl != null && comprobanteUrl.trim().isNotEmpty) ...[
                                                GestureDetector(
                                                  onTap: () => _mostrarComprobanteAmpliado(context, comprobanteUrl),
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
                                                            comprobanteUrl,
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
                                                            style: const TextStyle(color: Color(0xFF031A2E), fontWeight: FontWeight.bold, fontSize: 15),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () => _eliminarNotificacion(idNoti, index),
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
                                                      style: const TextStyle(color: Color(0xFF333333), fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (idPedido != null) ...[
                                            const SizedBox(height: 14),
                                            const Divider(color: Color(0xFFE0E0E0), height: 1),
                                            const SizedBox(height: 12),
                                            if (!accionRealizada)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () => _cambiarEstadoPedido(noti, 'RECHAZADO', setStateCard, () {
                                                      setStateCard(() {
                                                        accionRealizada = true;
                                                        estadoSeleccionado = 'RECHAZADO';
                                                      });
                                                    }),
                                                    icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                                                    label: const Text('Rechazar', style: TextStyle(color: Colors.red, fontSize: 12)),
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(color: Colors.red, width: 1.2),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton.icon(
                                                    onPressed: () => _cambiarEstadoPedido(noti, 'APROBADO', setStateCard, () {
                                                      setStateCard(() {
                                                        accionRealizada = true;
                                                        estadoSeleccionado = 'APROBADO';
                                                      });
                                                    }),
                                                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                                                    label: const Text('Aprobar', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: estadoSeleccionado == 'APROBADO' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  estadoSeleccionado == 'APROBADO' 
                                                      ? '✓ Pedido aprobado y notificado al cliente' 
                                                      : '✗ Pedido rechazado y notificado al cliente',
                                                  style: TextStyle(
                                                    color: estadoSeleccionado == 'APROBADO' ? Colors.green : Colors.red,
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
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}