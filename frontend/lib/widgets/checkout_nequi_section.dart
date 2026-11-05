import 'dart:io';
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:flutter/material.dart';

class CheckoutNequiSection extends StatelessWidget {
  final File? comprobanteImagen;
  final Uint8List? comprobanteBytes; // Añadido para Web
  final VoidCallback onSeleccionarComprobante;

  const CheckoutNequiSection({
    super.key,
    required this.comprobanteImagen,
    this.comprobanteBytes,
    required this.onSeleccionarComprobante,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A2E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos para transferencia Nequi:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Número: 3125190267\nTitular: Distribuidora Anita',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 14),
          const Text(
            'Comprobante de pago:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSeleccionarComprobante,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF031A2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00A2E8)),
              ),
              child: _mostrarVistaPrevia(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mostrarVistaPrevia() {
    // Si estamos en Web y tenemos los bytes de la imagen
    if (kIsWeb && comprobanteBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(comprobanteBytes!, fit: BoxFit.cover),
      );
    } 
    // Si estamos en Móvil y tenemos el archivo local
    else if (!kIsWeb && comprobanteImagen != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(comprobanteImagen!, fit: BoxFit.cover),
      );
    } 
    // Si no hay imagen seleccionada
    else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, color: Color(0xFF00A8FF), size: 30),
          SizedBox(height: 4),
          Text(
            'Toca para subir foto del comprobante',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      );
    }
  }
}