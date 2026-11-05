import 'package:flutter/material.dart';

class ProductoCard extends StatefulWidget {
  final String nombre;
  final String precioDetal;
  final String presentacion;
  final String tapa;
  final String imagenUrl;
  final Function(int cantidad)? onAgregarCarrito;

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
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  int _cantidad = 1;

  void _incrementar() {
    setState(() {
      _cantidad++;
    });
  }

  void _decrementar() {
    if (_cantidad > 1) {
      setState(() {
        _cantidad--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String detalleExtra = widget.presentacion;
    if (widget.tapa.isNotEmpty) {
      detalleExtra += ' - Tapa ${widget.tapa}';
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
          // Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.imagenUrl.isNotEmpty
                ? Image.network(
                    widget.imagenUrl,
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
          const SizedBox(width: 12),

          // Información del producto (Nombre, Precio, Presentación)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombre.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.precioDetal,
                  style: const TextStyle(
                    color: Color(0xFF00A8FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalleExtra.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detalleExtra,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ]
              ],
            ),
          ),

          // Controles compactos: selector pequeño y botón de carrito
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Selector de cantidad más pequeño (- 1 +)
              Container(
                height: 26,
                width: 85,
                decoration: BoxDecoration(
                  color: const Color(0xFF031A2E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF00A8FF), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: _decrementar,
                      child: const Icon(Icons.remove, color: Colors.white, size: 12),
                    ),
                    Text(
                      '$_cantidad',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: _incrementar,
                      child: const Icon(Icons.add, color: Colors.white, size: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Botón con icono de carrito de compras
              SizedBox(
                height: 32,
                width: 85,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8FF),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (widget.onAgregarCarrito != null) {
                      widget.onAgregarCarrito!(_cantidad);
                    }
                  },
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}