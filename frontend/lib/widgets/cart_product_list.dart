
import 'package:flutter/material.dart';
import 'package:frontend/widgets/cart.dart';

class CartProductList extends StatelessWidget {
  final List<dynamic> detallesCarrito;
  final Function(int, int) onCantidadChanged;
  final Function(int, bool) onToggleSeleccion;
  final Function(int) onEliminar;

  const CartProductList({
    super.key,
    required this.detallesCarrito,
    required this.onCantidadChanged,
    required this.onToggleSeleccion,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (detallesCarrito.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'Tu carrito está vacío',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detallesCarrito.length,
      itemBuilder: (context, index) {
        final item = detallesCarrito[index];
        final producto = item['productos'] ?? {};
        
        final nombre = producto['nombre'] ?? 'Producto';
        final presentacion = producto['presentacion'] ?? '';
        final tapa = producto['tapa'] ?? '';
        final imagenUrl = producto['imagen_url'] ?? '';
        final seleccionado = item['seleccionado'] ?? true; // 👈 Estado de selección

        return CartProductCardItem(
          index: index,
          nombre: nombre,
          precioUnitario: (item['precio_unitario'] as num).toDouble(),
          presentacion: presentacion,
          tapa: tapa,
          imagenUrl: imagenUrl,
          cantidad: item['cantidad'],
          seleccionadoInicial: seleccionado,
          onCantidadChanged: onCantidadChanged,
          onToggleSeleccion: onToggleSeleccion,
          onEliminar: onEliminar,
        );
      },
    );
  }
}