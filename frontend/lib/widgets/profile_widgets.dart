import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

/// AppBar personalizada para navegar entre Home, Notificaciones, Carrito y Perfil.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentScreen; // 'home', 'profile', 'notifications', 'cart'

  const CustomAppBar({
    super.key,
    this.currentScreen = '',
  });

  static const _barra = Color(0xFF063B5D);
  static const _celeste = Color(0xFF00A8FF);

  void _navegarA(BuildContext context, Widget screen, String name) {
    if (currentScreen == name) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _barra,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 110, // Ajustado a 110 para evitar desbordamiento
      leading: Row(
        children: [
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _navegarA(context, const HomeScreen(), 'home'),
            icon: Icon(
              Icons.home_outlined,
              color: currentScreen == 'home' ? _celeste : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // TODO: Navegar a pantalla de Notificaciones
            },
            icon: Icon(
              Icons.notifications_none,
              color: currentScreen == 'notifications' ? _celeste : Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navegar a pantalla del Carrito
          },
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: currentScreen == 'cart' ? _celeste : Colors.white,
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () => _navegarA(context, const ProfileScreen(), 'profile'),
          icon: Icon(
            Icons.person_outline,
            color: currentScreen == 'profile' ? _celeste : Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}