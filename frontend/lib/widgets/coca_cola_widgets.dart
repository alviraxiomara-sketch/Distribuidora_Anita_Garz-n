import 'package:flutter/material.dart';

class CocaColaProductCardItem extends StatelessWidget {
  final int index;
  final String nombre;
  final String precio;
  final String presentacion;
  final String imagenAsset;
  final int cantidad;
  final Function(int, int) onCantidadChanged;
  final VoidCallback onAgregarAlCarrito;

  const CocaColaProductCardItem({
    super.key,
    required this.index,
    required this.nombre,
    required this.precio,
    required this.presentacion,
    required this.imagenAsset,
    required this.cantidad,
    required this.onCantidadChanged,
    required this.onAgregarAlCarrito,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00A8FF).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                imagenAsset,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_drink,
                  color: Color(0xFF063B5D),
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Información del producto (Nombre, Precio, Presentación)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  precio,
                  style: const TextStyle(
                    color: Color(0xFF00A8FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  presentacion,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Controles de cantidad y botón Agregar al carrito
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Selector (- 1 +)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0073B7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A8FF), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                      onPressed: () => onCantidadChanged(index, -1),
                    ),
                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      onPressed: () => onCantidadChanged(index, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Botón Agregar al Carrito
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073B7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(115, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF00A8FF), width: 1),
                  ),
                ),
                onPressed: onAgregarAlCarrito,
                child: const Text(
                  'Agregar al\ncarrito',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}