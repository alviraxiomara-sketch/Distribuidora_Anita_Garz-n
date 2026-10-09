import 'package:flutter/material.dart';

// Modelo de datos para las categorías
class CategoriaItem {
  final String nombre;
  final String imagenAsset;

  const CategoriaItem({
    required this.nombre,
    required this.imagenAsset,
  });
}

// Banner de encabezado con logo circular a la izquierda y frases centradas
class HomeHeaderBanner extends StatelessWidget {
  const HomeHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF031A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo circular con borde azul claro
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF031A2E),
                border: Border.all(
                  color: const Color(0xFF00A8FF),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_drink,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Frases de bienvenida (centradas)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenidos a distribuciones\nde bebidas Anita',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontFamily: 'Georgia',
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Tu mejor opción en\npedidos y distribuciones de\nbebidas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta individual de categoría
class CategoriaCard extends StatelessWidget {
  final CategoriaItem categoria;

  const CategoriaCard({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00A8FF), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                categoria.imagenAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF063B5D),
                  child: const Icon(
                    Icons.local_drink,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          categoria.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Pie de página con información de contacto (más alto, como en Figma)
class HomeFooterContacts extends StatelessWidget {
  const HomeFooterContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF063B5D),
      padding: const EdgeInsets.only(top: 28, bottom: 44, left: 24, right: 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Contactanos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, color: Color(0xFFBCAAA4), size: 16),
              SizedBox(width: 8),
              Text(
                '3227328596',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.redAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'calle 4 a sur #16-05',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}