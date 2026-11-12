import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart';
import 'package:frontend/widgets/tarjeta_notificacion_admin.dart';

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

        // Marca todas como leídas en la BD al entrar a la pantalla
        await _marcarTodasComoLeidas();
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Marca como leídas todas las notificaciones del usuario en la BD
  Future<void> _marcarTodasComoLeidas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/marcar-todas-leidas'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Silencioso: si falla, el badge volverá a aparecer
    }
  }

  // Guarda en la BD si la notificación fue APROBADA o RECHAZADA
  Future<void> _guardarEstadoAccion(dynamic idNotificacion, String estado) async {
    if (idNotificacion == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/$idNotificacion/estado-accion'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': estado}),
      );
    } catch (_) {}
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
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _cambiarEstadoPedido(
      Map<String, dynamic> notificacion, String nuevoEstado) async {
    int? pedidoId = notificacion['id_pedido'] != null
        ? int.tryParse(notificacion['id_pedido'].toString())
        : null;

    if (pedidoId == null) {
      try {
        final textoCompleto =
            '${notificacion['titulo'] ?? ''} ${notificacion['mensaje'] ?? ''}';
        final match = RegExp(r'#(\d+)').firstMatch(textoCompleto);
        if (match != null) pedidoId = int.parse(match.group(1)!);
      } catch (_) {}
    }

    if (pedidoId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo identificar el ID del pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
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
        // Guarda en la BD para que los botones no vuelvan a aparecer
        await _guardarEstadoAccion(notificacion['id_notificacion'], nuevoEstado);
        notificacion['estado_accion'] = nuevoEstado;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Pedido #$pedidoId ${nuevoEstado.toLowerCase()} exitosamente y cliente notificado'),
            backgroundColor:
                nuevoEstado == 'APROBADO' ? Colors.green : Colors.red,
          ),
        );
        return true;
      } else {
        final decoded = jsonDecode(res.body);
        throw Exception(decoded['error'] ?? 'Error al actualizar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
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
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
          ),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF384E5E).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00A8FF), width: 2),
          ),
          child: Column(
            children: [
              // Etiqueta superior, igual que en la pantalla del cliente
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF084B75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
                ),
                child: const Text(
                  'Historial de Notificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
                      : _notificaciones.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay notificaciones de pedidos',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _notificaciones.length,
                              itemBuilder: (context, index) {
                                final noti = _notificaciones[index];
                                final idNoti =
                                    noti['id_notificacion'] ?? noti['id'] ?? index;

                                return TarjetaNotificacionAdmin(
                                  notificacion: noti,
                                  onEliminar: () => _eliminarNotificacion(idNoti, index),
                                  onVerComprobante: (url) =>
                                      _mostrarComprobanteAmpliado(context, url),
                                  onCambiarEstado: (estado) =>
                                      _cambiarEstadoPedido(noti, estado),
                                );
                              },
                            ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}