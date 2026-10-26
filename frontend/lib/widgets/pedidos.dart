import 'package:flutter/material.dart';

class BadgePedidos extends StatelessWidget {
  const BadgePedidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF084B75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A8FF), width: 1.5),
      ),
      child: const Text(
        'Pedidos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}