import 'package:flutter/material.dart';
import 'package:frontend/screens/gaseosas_screen.dart';
import 'package:frontend/screens/jugos_screen.dart';
import 'package:frontend/widgets/home_widgets.dart';

class AppDrawer extends StatelessWidget {
  final List<CategoriaItem> categorias;

  const AppDrawer({
    super.key,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF031A2E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // CABECERA: Logo de Distribuidora Anita
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF063B5D),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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

          // TÍTULO SECCIÓN
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

          // LISTADO DE CATEGORÍAS
          ...categorias.map((cat) {
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00A8FF), width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        cat.imagenAsset,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_drink,
                          color: Colors.black54,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    cat.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00A8FF),
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    if (cat.nombre == 'Gaseosas') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CatalogoProductosScreen(),
                        ),
                      );
                    } else if (cat.nombre == 'Jugos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JugosScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Categoría ${cat.nombre} próximamente disponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFF00A8FF),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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