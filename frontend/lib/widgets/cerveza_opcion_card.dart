import 'package:flutter/material.dart';

class CervezaOpcionCard extends StatelessWidget {
  final String titulo;
  final VoidCallback? onTap;

  const CervezaOpcionCard({
    super.key,
    required this.titulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF063B5D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00A8FF),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF00A8FF),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}