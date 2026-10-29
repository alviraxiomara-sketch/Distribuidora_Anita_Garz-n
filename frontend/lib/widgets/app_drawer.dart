import 'package:flutter/material.dart';
import 'package:frontend/screens/tipos.dart'; // <--- Asegúrate de importar la pantalla Tipos

class AppDrawer extends StatelessWidget {
  final List<dynamic> categorias;
  final bool isLoading;

  const AppDrawer({
    super.key, 
    required this.categorias, 
    this.isLoading = false,
  });

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
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00A8FF), width: 2),
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
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Distribuidora\nAnita',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Text(
              'CATEGORÍAS',
              style: TextStyle(
                color: Color(0xFF00A8FF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          
          if (isLoading == true)
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00A8FF)),
              ),
            )
          else if (categorias.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No hay categorías registradas',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            )
          else
            ...categorias.map((cat) {
              String nombre = 'Sin nombre';
              if (cat is Map) {
                nombre = cat['nombre'] ?? cat['Nombre'] ?? 'Sin nombre';
              } else {
                try {
                  nombre = (cat as dynamic).nombre;
                } catch (_) {
                  nombre = cat.toString();
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF063B5D).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00A8FF).withOpacity(0.4),
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text(
                      nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF00A8FF),
                      size: 14,
                    ),
                    onTap: () {
                      // 1. Cierra el menú lateral
                      Navigator.of(context).pop();

                      // 2. Navega correctamente a la pantalla TiposScreen pasando la categoría
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TiposScreen(categoria: nombre),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}