import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
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
          // CABECERA: Logo con borde azul y texto al lado
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
                    radius: 37,
                    backgroundColor: const Color(0xFF00A8FF),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 70,
                        height: 70,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ESPACIO PARA EL TÍTULO DE CATEGORÍAS
          const SizedBox(height: 15),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              'CATEGORÍAS',
              style: TextStyle(
                color: Color(0xFF00A8FF),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // LISTA DE CATEGORÍAS DENTRO DE TARJETAS ESTILIZADAS CON BORDE AZUL
          ...categorias.map((cat) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF063B5D).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00A8FF).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        cat.imagenAsset,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_drink,
                          color: Colors.black54,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    cat.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00A8FF),
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a la categoría seleccionada
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