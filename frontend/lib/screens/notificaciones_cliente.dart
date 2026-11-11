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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _categoriasList = [];
  List<dynamic> _notificacionesList = [];
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

        setState(() {
          _notificacionesList = lista;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      drawer: AppDrawer(categorias: _categoriasList),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        title: const Text('Mis Notificaciones', style: TextStyle(color: Colors.white, fontSize: 18)),
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
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
                    const Text(
                      'Historial de Notificaciones',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: CircularProgressIndicator(color: Color(0xFF00A8FF)),
                          )
                        : _notificacionesList.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Text('No tienes notificaciones', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: _notificacionesList.length,
                                  itemBuilder: (context, index) {
                                    final noti = _notificacionesList[index];
                                    final idNoti = noti['id_notificacion'] ?? noti['id'];
                                    final String titulo = noti['titulo'] ?? 'Notificación';
                                    final String mensaje = noti['mensaje'] ?? '';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        title: Text(titulo, style: const TextStyle(color: Color(0xFF031A2E), fontWeight: FontWeight.bold, fontSize: 14)),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(mensaje, style: const TextStyle(color: Color(0xFF333333), fontSize: 13, height: 1.3)),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                          onPressed: () => _eliminarNotificacion(idNoti),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}