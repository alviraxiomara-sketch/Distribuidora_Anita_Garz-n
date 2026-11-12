import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/cart_screen.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';

class NotificacionesCliente extends StatefulWidget {
  const NotificacionesCliente({super.key});

  @override
  State<NotificacionesCliente> createState() => _NotificacionesClienteState();
}

class _NotificacionesClienteState extends State<NotificacionesCliente> {
  static const _fondo = Color(0xFF031A2E);
  static const _tarjeta = Color(0xFF063B5D);
  static const _azul = Color(0xFF00A8FF);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _categoriasList = [];
  List<dynamic> _notificacionesList = [];
  // Ids de las notificaciones que estaban sin leer al abrir la pantalla
  Set<dynamic> _nuevas = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarNotificacionesYMarcarLeidas();
  }

  Future<void> _cargarCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        setState(() {
          _categoriasList = decoded is List ? decoded : [];
        });
      }
    } catch (_) {}
  }

  Future<void> _cargarNotificacionesYMarcarLeidas() async {
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

        // Guarda cuáles eran nuevas antes de marcarlas como leídas
        final nuevas = <dynamic>{};
        for (var item in lista) {
          final bool leido = item['leido'] ?? item['leida'] ?? false;
          if (!leido) nuevas.add(item['id_notificacion'] ?? item['id']);
        }

        setState(() {
          _notificacionesList = lista;
          _nuevas = nuevas;
          _isLoading = false;
        });

        // Marcar automáticamente como leídas en el servidor al abrirlas
        for (var item in lista) {
          final bool leido = item['leido'] ?? item['leida'] ?? false;
          if (!leido) {
            final idNotif = item['id_notificacion'] ?? item['id'];
            if (idNotif != null) {
              await _marcarNotificacionComoLeidaServidor(idNotif, token);
            }
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _marcarNotificacionComoLeidaServidor(dynamic id, String? token) async {
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id/leida'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {}
  }

  Future<void> _eliminarNotificacion(dynamic id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id/eliminar'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        setState(() {
          _notificacionesList.removeWhere((item) => (item['id_notificacion'] ?? item['id']) == id);
        });
      }
    } catch (_) {}
  }

  // ---------- Helpers de presentación ----------

  // Elige icono y color según el contenido de la notificación
  ({IconData icono, Color color}) _estiloNotificacion(String titulo, String mensaje) {
    final t = '$titulo $mensaje'.toLowerCase();
    if (t.contains('aprob')) {
      return (icono: Icons.check_circle_outline_rounded, color: Colors.greenAccent);
    }
    if (t.contains('rechaz') || t.contains('cancel')) {
      return (icono: Icons.cancel_outlined, color: Colors.redAccent);
    }
    if (t.contains('stock')) {
      return (icono: Icons.inventory_2_outlined, color: const Color(0xFFFFA726));
    }
    if (t.contains('pedido') || t.contains('envi') || t.contains('entreg')) {
      return (icono: Icons.local_shipping_outlined, color: _azul);
    }
    return (icono: Icons.notifications_none_rounded, color: _azul);
  }

  String? _formatearFecha(dynamic noti) {
    final raw = noti['fecha'] ?? noti['created_at'] ?? noti['fecha_creacion'] ?? noti['fecha_notificacion'];
    if (raw == null) return null;
    final d = DateTime.tryParse(raw.toString())?.toLocal();
    if (d == null) return null;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year}  ${dos(d.hour)}:${dos(d.minute)}';
  }

  Widget _buildTarjeta(dynamic noti) {
    final idNoti = noti['id_notificacion'] ?? noti['id'];
    final String titulo = (noti['titulo'] ?? 'Notificación').toString();
    final String mensaje = (noti['mensaje'] ?? '').toString();
    final fecha = _formatearFecha(noti);
    final esNueva = _nuevas.contains(idNoti);
    final estilo = _estiloNotificacion(titulo, mensaje);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: _tarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esNueva ? _azul : _azul.withOpacity(0.5),
          width: esNueva ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _fondo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(estilo.icono, color: estilo.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (esNueva)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NUEVA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (mensaje.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    mensaje,
                    style: const TextStyle(
                      color: Color(0xFFB0BEC5),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
                if (fecha != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: _azul, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        fecha,
                        style: const TextStyle(color: _azul, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 21),
            onPressed: () => _eliminarNotificacion(idNoti),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _fondo,
      drawer: AppDrawer(categorias: _categoriasList),
      appBar: AppBar(
        backgroundColor: _tarjeta,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
            border: Border.all(color: _azul, width: 2),
          ),
          child: Column(
            children: [
              // Etiqueta superior, mismo estilo que "inventario"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF084B75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _azul, width: 1.5),
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
                    ? const Center(child: CircularProgressIndicator(color: _azul))
                    : _notificacionesList.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_off_outlined, color: Colors.white38, size: 46),
                                SizedBox(height: 10),
                                Text(
                                  'No tienes notificaciones',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notificacionesList.length,
                            itemBuilder: (context, index) => _buildTarjeta(_notificacionesList[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}