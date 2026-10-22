import 'package:flutter/material.dart';

class ProductCardItem extends StatelessWidget {
  final String nombre;
  final String imagenAsset;
  final VoidCallback? onTap;

  const ProductCardItem({
    super.key,
    required this.nombre,
    required this.imagenAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00A8FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Contenedor de la imagen con diseño unificado
                Container(
                  width: 75,
                  height: 75,
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
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover, // <--- Ajustado para que cubra todo el recuadro igual que la primera
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink,
                        color: Color(0xFF063B5D),
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Nombre del producto
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Flecha indicadora
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF00A8FF),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}