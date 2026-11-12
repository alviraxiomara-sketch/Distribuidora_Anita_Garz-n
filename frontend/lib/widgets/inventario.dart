import 'package:flutter/material.dart';

/// Un producto se considera AGOTADO cuando su stock es menor o igual a este valor.
///  - 0 -> agotado solo cuando llega a 0 (requiere que la BD permita stock 0)
///  - 1 -> agotado cuando queda 1 unidad (útil si la BD no deja llegar a 0)
const int kStockAgotadoHasta = 0;

/// Etiqueta superior "inventario"
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

/// Resumen rápido: total de productos, con stock bajo y agotados
class InventarioResumen extends StatelessWidget {
  final int total;
  final int bajos;
  final int agotados;

  const InventarioResumen({
    super.key,
    required this.total,
    required this.bajos,
    required this.agotados,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _caja('Productos', total, const Color(0xFF00A8FF),
              Icons.inventory_2_outlined),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _caja('Stock bajo', bajos, const Color(0xFFFFA726),
              Icons.warning_amber_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _caja('Agotados', agotados, Colors.redAccent,
              Icons.remove_shopping_cart_outlined),
        ),
      ],
    );
  }

  Widget _caja(String titulo, int valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            '$valor',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de producto del inventario
class InventarioItemCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final String? categoria;
  final VoidCallback? onEditar;

  const InventarioItemCard({
    super.key,
    required this.producto,
    this.categoria,
    this.onEditar,
  });

  int _aInt(dynamic v) => (num.tryParse(v?.toString() ?? '') ?? 0).round();

  String _formatoPrecio(dynamic v) {
    final n = num.tryParse(v?.toString() ?? '');
    if (n == null) return '\$${v ?? 0}';
    final s = n.round().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '\$${b.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final p = producto['productos'] ?? producto;
    final nombre = (p['nombre'] ?? producto['nombre'] ?? 'Producto').toString();
    final precio = p['precio_detal'] ?? p['precio'] ?? 0;
    final presentacion = (p['presentacion'] ?? 'Unidad').toString();
    final imagenUrl = p['imagen_url'] ?? producto['imagen_url'];

    final stockActual = _aInt(producto['stock_actual'] ?? producto['cantidad']);
    final stockMinimo = _aInt(producto['stock_minimo'] ?? 20);

    late final Color color;
    late final String estado;
    if (stockActual <= kStockAgotadoHasta) {
      color = Colors.red;
      estado = 'Agotado';
    } else if (stockActual < stockMinimo) {
      color = const Color(0xFFE67E22);
      estado = 'Stock bajo';
    } else {
      color = const Color(0xFF2E9E4F);
      estado = 'Disponible';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: const Color(0xFFD9D9D9),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Franja de color según el estado del stock
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagenMiniatura(imagenUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _chip(presentacion,
                                          const Color(0xFF063B5D), Colors.white),
                                      if (categoria != null &&
                                          categoria!.isNotEmpty)
                                        _chip(categoria!, Colors.white,
                                            const Color(0xFF063B5D)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _formatoPrecio(precio),
                                        style: const TextStyle(
                                          color: Color(0xFF063B5D),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'precio detal',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: onEditar,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF063B5D),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_outlined,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: Colors.black26),
                        ),
                        Row(
                          children: [
                            Text(
                              '$stockActual',
                              style: TextStyle(
                                color: color,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'UD en stock',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              'Mín: $stockMinimo',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 11),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                estado,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String texto, Color fondo, Color textoColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF063B5D), width: 0.8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: textoColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImagenMiniatura(String? url) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: (url != null && url.isNotEmpty && url.startsWith('http'))
            ? Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_drink_rounded,
                    color: Color(0xFF031A2E),
                    size: 28),
              )
            : Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_drink_rounded,
                    color: Color(0xFF031A2E),
                    size: 28),
              ),
      ),
    );
  }
}