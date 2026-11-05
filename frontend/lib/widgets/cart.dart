import 'package:flutter/material.dart';

class CartProductCardItem extends StatefulWidget {
  final int index;
  final String nombre;
  final double precioUnitario;
  final String presentacion;
  final String tapa;
  final String imagenUrl;
  final int cantidad;
  final bool seleccionadoInicial;
  final Function(int, int) onCantidadChanged;
  final Function(int, bool) onToggleSeleccion;
  final Function(int) onEliminar;

  const CartProductCardItem({
    super.key,
    required this.index,
    required this.nombre,
    required this.precioUnitario,
    required this.presentacion,
    required this.tapa,
    required this.imagenUrl,
    required this.cantidad,
    this.seleccionadoInicial = true,
    required this.onCantidadChanged,
    required this.onToggleSeleccion,
    required this.onEliminar,
  });

  @override
  State<CartProductCardItem> createState() => _CartProductCardItemState();
}

class _CartProductCardItemState extends State<CartProductCardItem> {
  late bool _estaSeleccionado;

  @override
  void initState() {
    super.initState();
    _estaSeleccionado = widget.seleccionadoInicial;
  }

  @override
  Widget build(BuildContext context) {
    String detalleTexto = widget.presentacion;
    if (widget.tapa.isNotEmpty) {
      detalleTexto += detalleTexto.isNotEmpty ? ' - Tapa ${widget.tapa}' : 'Tapa ${widget.tapa}';
    }

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
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imagenUrl.isNotEmpty
                  ? Image.network(
                      widget.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_drink,
                        color: Colors.white,
                        size: 35,
                      ),
                    )
                  : const Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 35,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombre.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${widget.precioUnitario.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF00A8FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalleTexto.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detalleTexto,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Controles de cantidad y acciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cuadro de cantidad cuadrado y oscuro
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF021B2E),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF00A2E8),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28),
                      onPressed: () => widget.onCantidadChanged(widget.index, -1),
                      icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                    ),
                    Text(
                      '${widget.cantidad}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28),
                      onPressed: () => widget.onCantidadChanged(widget.index, 1),
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Papelera y Checkbox interactivo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => widget.onEliminar(widget.index),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      setState(() {
                        _estaSeleccionado = !_estaSeleccionado;
                      });
                      widget.onToggleSeleccion(widget.index, _estaSeleccionado);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _estaSeleccionado ? const Color(0xFF00A2E8) : Colors.white70,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: _estaSeleccionado ? const Color(0xFF00A2E8) : Colors.transparent,
                      ),
                      child: _estaSeleccionado
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
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