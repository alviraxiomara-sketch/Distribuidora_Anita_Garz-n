import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart';
import 'package:frontend/widgets/notificaciones.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificacionesBD();
  }

  // Carga notificaciones desde la base de datos vía API REST
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
      
      // Menú lateral del Administrador integrado
      drawer: const AdminDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        // Ancho ampliado para alojar ambos botones con su debida separación
        leadingWidth: 110,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            // 1. Botón de Menú de Hamburguesa (Abre el Drawer)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(width: 16), // Separación entre la hamburguesa y la casita
            // 2. Botón de la Casita (Dirige a PrincipalAdminScreen)
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
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
          // Ícono de perfil (persona) -> Dirige a profile.dart
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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

            // Contenedor principal de notificaciones
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 480),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF384E5E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00A8FF),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const BadgePedidos(),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF00A8FF)),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notificaciones.length,
                      itemBuilder: (context, index) {
                        final item = _notificaciones[index];
                        final idNotif = item['id'] ?? item['id_notificacion'] ?? index;
                        
                        return NotificacionItemCard(
                          notificacion: item,
                          onDelete: () => _eliminarNotificacion(idNotif, index),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}