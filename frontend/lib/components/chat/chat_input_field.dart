import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;
  final bool cargando;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.cargando,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241, 242, 243),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: TextField(
                controller: controller,
                enabled: !cargando,
                decoration: const InputDecoration(
                  hintText: 'Pregunta por productos, precios...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => onEnviar(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: cargando ? null : onEnviar,
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 248, 247, 247),
              foregroundColor: const Color.fromARGB(255, 15, 0, 0),
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}