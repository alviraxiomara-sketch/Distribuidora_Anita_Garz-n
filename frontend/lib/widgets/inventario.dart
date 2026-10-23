import 'package:flutter/material.dart';

/// Widget para la etiqueta superior "inventario"
class BadgeInventario extends StatelessWidget {
  const BadgeInventario({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF084B75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
      ),
      child: const Text(
        'inventario',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget optimizado para cada tarjeta de producto en el inventario[cite: 13]
class InventarioItemCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback? onEditar;

  const InventarioItemCard({
    super.key,
    required this.producto,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final p = producto['productos'] ?? producto;
    final nombre = p['nombre'] ?? producto['nombre'] ?? 'Producto';
    final precio = p['precio_detal']?.toString() ?? p['precio']?.toString() ?? '0';
    final presentacion = p['presentacion'] ?? 'Unidad';
    
    final stockActual = producto['stock_actual'] ?? producto['cantidad'] ?? 0;
    final stockMinimo = producto['stock_minimo'] ?? 20;
    final imagenUrl = p['imagen_url'] ?? producto['imagen_url'];
    final stockColor = stockActual < stockMinimo ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildImagenMiniatura(imagenUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('\$$precio', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(presentacion, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF063B5D), size: 20),
                onPressed: onEditar,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$stockActual', style: TextStyle(color: stockColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  const Text('UD', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagenMiniatura(String? url) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (url != null && url.isNotEmpty && url.startsWith('http'))
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.local_drink_rounded, color: Color(0xFF031A2E), size: 24),
              )
            : Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.local_drink_rounded, color: Color(0xFF031A2E), size: 24),
              ),
      ),
    );
  }
}