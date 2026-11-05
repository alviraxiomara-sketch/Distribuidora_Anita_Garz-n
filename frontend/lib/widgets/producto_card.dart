import 'package:flutter/material.dart';

class ProductoCard extends StatelessWidget {
  final String nombre;
  final String precioDetal;
  final String presentacion;
  final String tapa;
  final String imagenUrl;
  final VoidCallback? onAgregarCarrito;

  const ProductoCard({
    super.key,
    required this.nombre,
    required this.precioDetal,
    required this.presentacion,
    required this.tapa,
    required this.imagenUrl,
    this.onAgregarCarrito,
  });

  @override
  Widget build(BuildContext context) {
    // Construimos detalles adicionales (ej. "Media - Tapa Negra")
    String detalleExtra = presentacion;
    if (tapa.isNotEmpty) {
      detalleExtra += ' - Tapa $tapa';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00A8FF),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Imagen del producto desde Cloudinary / URL
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagenUrl.isNotEmpty
                ? Image.network(
                    imagenUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.white12,
                    child: const Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 30,
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
                  nombre.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  precioDetal,
                  style: const TextStyle(
                    color: Color(0xFF00A8FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalleExtra.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detalleExtra,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ]
              ],
            ),
          ),

          // Botón para agregar al carrito
          IconButton(
            onPressed: onAgregarCarrito,
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Color(0xFF00A8FF),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}