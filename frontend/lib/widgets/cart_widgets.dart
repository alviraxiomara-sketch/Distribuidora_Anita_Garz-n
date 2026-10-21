import 'package:flutter/material.dart';

class CartProductCardItem extends StatelessWidget {
  final int index;
  final String nombre;
  final double precioUnitario;
  final String presentacion;
  final String imagenAsset;
  final int cantidad;
  final bool seleccionado;
  final Function(int, int) onCantidadChanged;
  final Function(int) onToggleSeleccion;
  final Function(int) onEliminar;

  const CartProductCardItem({
    super.key,
    required this.index,
    required this.nombre,
    required this.precioUnitario,
    required this.presentacion,
    required this.imagenAsset,
    required this.cantidad,
    required this.seleccionado,
    required this.onCantidadChanged,
    required this.onToggleSeleccion,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final double subtotal = precioUnitario * cantidad;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00A2E8),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del producto
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagenAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_drink,
                  color: Color(0xFF063B5D),
                  size: 35,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detalles del producto (Nombre, Precio, Presentación)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${precioUnitario.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  presentacion,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Control de Cantidad, Subtotal y Acciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Controles de cantidad (- 1 +) y botón eliminar
              Row(
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          onPressed: () => onCantidadChanged(index, -1),
                          icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                        ),
                        Text(
                          '$cantidad',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          onPressed: () => onCantidadChanged(index, 1),
                          icon: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onEliminar(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Botón indicador de Subtotal y Checkbox
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onToggleSeleccion(index),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                        color: seleccionado ? const Color(0xFF00A2E8) : Colors.transparent,
                      ),
                      child: seleccionado
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}