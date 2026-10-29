import 'package:flutter/material.dart';

class ItemCatalogoCard extends StatelessWidget {
  final String titulo;
  final VoidCallback onTap;

  const ItemCatalogoCard({
    super.key,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00A8FF).withOpacity(0.6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF063B5D),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF00A8FF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}