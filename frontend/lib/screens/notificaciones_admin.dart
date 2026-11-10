import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart';
import 'package:frontend/widgets/notificaciones.dart';

class NotificacionesAdmin extends StatefulWidget {
  const NotificacionesAdmin({super.key});

  @override
  State<NotificacionesAdmin> createState() => _NotificacionesAdminState();
}

class _NotificacionesAdminState extends State<NotificacionesAdmin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificacionesBD();
  }

  // Carga notificaciones desde la base de datos y marca automáticamente las no leídas
  Future<void> _cargarNotificacionesBD() async {
    setState(() => _isLoading = true);
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
        } else if (decoded is Map && decoded['data'] is List) {
          lista = decoded['data'];
        }

        // Marcar automáticamente como leídas en el servidor las pendientes
        for (var item in lista) {
          final bool leido = item['leido'] ?? item['leida'] ?? false;
          if (!leido) {
            final idNotif = item['id_notificacion'] ?? item['id'];
            if (idNotif != null) {
              _marcarNotificacionComoLeidaServidor(idNotif, token);
            }
          }
        }

        setState(() {
          _notificaciones = lista;
          _isLoading = false;
        });
      } else {
        _usarDatosPrueba();
      }
    } catch (_) {
      _usarDatosPrueba();
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

  // Datos mock para visualización si la API aún no responde
  void _usarDatosPrueba() {
    if (!mounted) return;
    setState(() {
      _notificaciones = [
        {'id': 1, 'mensaje': 'Tu pedido ya sera entregado'},
        {'id': 2, 'mensaje': 'Tu pedido ya fue exitoso!!'},
        {'id': 3, 'mensaje': 'Tu pedido ya fue exitoso!!'},
      ];
      _isLoading = false;
    });
  }

  // Extraer el ID del pedido del mensaje (ej: "Nuevo pedido #7 de...")
  int? _extraerIdPedido(String mensaje) {
    try {
      final regExp = RegExp(r'#(\d+)');
      final match = regExp.firstMatch(mensaje);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    } catch (_) {}
    return null;
  }

  // Función para aprobar o rechazar el pedido desde la notificación del admin
  Future<void> _actualizarEstadoPedido(String mensaje, String estado) async {
    final pedidoId = _extraerIdPedido(mensaje);
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
        body: jsonEncode({'estado': estado}),
      );

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido #$pedidoId ${estado.toLowerCase()} exitosamente y cliente notificado'),
            backgroundColor: estado == 'APROBADO' ? Colors.green : Colors.red,
          ),
        );
        _cargarNotificacionesBD();
      } else {
        final decoded = jsonDecode(res.body);
        throw Exception(decoded['error'] ?? 'Error al actualizar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Eliminar una notificación conectada al backend
  Future<void> _eliminarNotificacion(dynamic id, int index) async {
    setState(() {
      _notificaciones.removeAt(index);
    });

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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF031A2E),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        leadingWidth: 130,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrincipalAdminScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 20),
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
                    const BadgePedidos(),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF00A8FF),
                        ),
                      )
                    else if (_notificaciones.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'No tienes notificaciones pendientes',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: _notificaciones.length,
                          itemBuilder: (context, index) {
                            final item = _notificaciones[index];
                            final idNotif =
                                item['id'] ?? item['id_notificacion'] ?? index;
                            final mensaje = item['mensaje'] ?? '';

                            return NotificacionItemCard(
                              notificacion: item,
                              onDelete: () => _eliminarNotificacion(idNotif, index),
                              onCambiarEstado: (nuevoEstado) {
                                _actualizarEstadoPedido(mensaje, nuevoEstado);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}