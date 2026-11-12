import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutFormFields extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController telefonoController;
  final String? metodoPago;
  final ValueChanged<String?> onMetodoPagoChanged;

  const CheckoutFormFields({
    super.key,
    required this.nombreController,
    required this.direccionController,
    required this.telefonoController,
    required this.metodoPago,
    required this.onMetodoPagoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: nombreController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Nombre completo'),
          validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: direccionController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Dirección de entrega'),
          validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: telefonoController,
          keyboardType: TextInputType.phone,
          // Solo números y máximo 10 dígitos
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Teléfono de contacto'),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Campo requerido';
            if (val.length != 10) return 'El teléfono debe tener 10 números';
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Método de pago:',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF063B5D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00A2E8), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: metodoPago,
              hint: const Text(
                'Seleccione método de pago',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF063B5D),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00A8FF)),
              items: ['Nequi', 'Contraentrega']
                  .map((metodo) => DropdownMenuItem(
                        value: metodo,
                        child: Text(metodo),
                      ))
                  .toList(),
              onChanged: onMetodoPagoChanged,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF063B5D),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00A2E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00A8FF), width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}