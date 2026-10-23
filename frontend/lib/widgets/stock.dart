import 'package:flutter/material.dart';

class BadgeStock extends StatelessWidget {
  const BadgeStock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF084B75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Stock',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.inventory_2_outlined, color: Colors.amber, size: 20),
        ],
      ),
    );
  }
}

class StockItemCard extends StatelessWidget {
  final Map<String, dynamic> producto;

  const StockItemCard({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    final prodInfo = producto['productos'] ?? producto;

    final String nombre = prodInfo['nombre'] ?? producto['nombre'] ?? 'Producto';
    final String presentacion = prodInfo['presentacion'] ?? prodInfo['tipo'] ?? 'Unidad';
    
    // Mostramos el stock actual en rojo para ver cuántas unidades quedan en alerta
    final int stockActual = producto['stock_actual'] ?? producto['cantidad'] ?? 0;
    final int stockMinimo = producto['stock_minimo'] ?? 0;
    
    final String? imagenUrl = prodInfo['imagen_url'] ?? prodInfo['imagen'] ?? producto['imagen_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagenUrl != null && imagenUrl.isNotEmpty
                  ? Image.network(
                      imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink,
                        color: Color(0xFF031A2E),
                      ),
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_drink,
                        color: Color(0xFF031A2E),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  presentacion,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mínimo requerido: $stockMinimo',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$stockActual',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'UD',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}