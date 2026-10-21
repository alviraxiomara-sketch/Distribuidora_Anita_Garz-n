import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'carrito_service.dart';

Future<void> manejarAgregarAlCarrito(
  BuildContext context,
  dynamic idProducto,
  int cantidad,
) async {
  try {
    await CarritoService.agregarAlCarrito(
      idProducto: idProducto,
      cantidad: cantidad,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Producto agregado al carrito!'),
        backgroundColor: Color.fromARGB(255, 72, 180, 230),
        duration: Duration(seconds: 2),
      ),
    );
  } on NoSesionException catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );

    // Redirige al usuario al Login si no ha iniciado sesión
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }
}