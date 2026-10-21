import 'package:flutter/material.dart';

class JugoCategoryCard extends StatelessWidget {
  final String nombre;
  final String imagenAsset;
  final VoidCallback onTap;

  const JugoCategoryCard({
    super.key,
    required this.nombre,
    required this.imagenAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00A2E8), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          // Aumentamos el padding vertical para hacer la tarjeta más alta
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          leading: Container(
            // Aumentamos el tamaño del recuadro del logo a 70x70
            width: 60,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagenAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_drink,
                    color: Color(0xFF063B5D),
                    size: 35,
                  );
                },
              ),
            ),
          ),
          title: Text(
            nombre,
            style: const TextStyle(
              fontSize: 20, // Texto un poco más grande
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF00A2E8),
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}