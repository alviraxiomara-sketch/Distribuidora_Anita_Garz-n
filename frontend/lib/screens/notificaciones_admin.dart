import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/notificaciones_admin_card.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_config.dart';


class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() => _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen> {
  List<dynamic> _notificaciones = [];
  bool _cargando = true;

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
        setState(() {
          _notificaciones = jsonDecode(res.body);
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarEstadoPedido(int idPedido, String nuevoEstado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/pedidos/$idPedido/estado-y-notificar'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': nuevoEstado}),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido $nuevoEstado correctamente'), backgroundColor: Colors.green),
        );
        _cargarNotificaciones();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        title: const Text('Notificaciones de Administrador', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A2E8)))
          : _notificaciones.isEmpty
              ? const Center(
                  child: Text('No hay notificaciones', style: TextStyle(color: Colors.white70, fontSize: 16)),
                )
              : ListView.builder(
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final noti = _notificaciones[index];
                    return NotificacionAdmin(
                      notificacion: noti,
                      onCambiarEstado: _cambiarEstadoPedido,
                    );
                  },
                ),
    );
  }
}