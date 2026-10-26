import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/ingresar_producto.dart';
import 'package:frontend/screens/inventario.dart'; // <--- 1. Asegúrate de importar la pantalla de Inventario
import 'package:frontend/screens/notificaciones_admin.dart';
import 'package:frontend/screens/stock.dart';
import 'package:frontend/services/api_config.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  int _notificacionesPendientes = 0;

  @override
  void initState() {
    super.initState();
    _obtenerNotificacionesPendientes();
  }

  // Consulta al backend para contar cuántas notificaciones no han sido leídas
  Future<void> _obtenerNotificacionesPendientes() async {
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

        // Filtra únicamente las notificaciones que no han sido leídas
        final noLeidas = lista.where((item) {
          final bool leido = item['leido'] ?? item['leida'] ?? false;
          return !leido;
        }).toList();

        setState(() {
          _notificacionesPendientes = noLeidas.length;
        });
      }
    } catch (_) {
      // Manejo silencioso en caso de error de red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF031A2E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF063B5D)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00A8FF),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF00A8FF),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_drink,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribuidora\nAnita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A8FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00A8FF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFF00A8FF),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'MODO ADMIN',
                              style: TextStyle(
                                color: Color(0xFF00A8FF),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'GESTIÓN DE SISTEMA',
              style: TextStyle(
                color: Color(0xFF00A8FF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // 2. Opción Inventario conectada a InventarioScreen
          _buildAdminOption(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Inventario',
            subtitle: 'Catálogo de productos',
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventarioScreen(),
                ),
              );
            },
          ),

          // Opción Control de Stock conectada a ControlStockScreen
          _buildAdminOption(
            context: context,
            icon: Icons.numbers_rounded,
            title: 'Control de Stock',
            subtitle: 'Existencias y cantidades',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ControlStockScreen(),
                ),
              );
            },
          ),

          _buildAdminOption(
            context: context,
            icon: Icons.add_circle_outline_rounded,
            title: 'Agregar Producto',
            subtitle: 'Crear nuevo ítem',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IngresarProductoScreen(),
                ),
              );
            },
          ),

          // Opción Notificaciones con badge dinámico
          _buildAdminOption(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'Notificaciones',
            subtitle: 'Alertas de pedidos y stock',
            badgeCount: _notificacionesPendientes > 0 ? _notificacionesPendientes : null,
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificacionesAdmin(),
                ),
              );
              _obtenerNotificacionesPendientes();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAdminOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF063B5D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00A8FF).withOpacity(0.6),
            width: 1.2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF031A2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00A8FF), size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
          ),
          trailing: badgeCount != null && badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF00A8FF),
                  size: 14,
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}