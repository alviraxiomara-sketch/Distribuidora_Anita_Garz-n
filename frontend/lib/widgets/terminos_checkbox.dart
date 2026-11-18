import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Muestra el diálogo con los Términos, Políticas y Condiciones.
void mostrarTerminos(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF063B5D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF00A8FF), width: 2),
      ),
      title: const Text(
        'Términos, Políticas y Condiciones',
        style: TextStyle(
          fontFamily: 'Georgia',
          color: Color(0xFF00A8FF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const SingleChildScrollView(
        child: Text(
          'Bienvenido a la aplicación de Distribuidora Anita Garzón.\n\n'
          '1. Protección de Datos: Al registrarte autorizas el tratamiento de '
          'tus datos personales para fines de gestión de pedidos, entregas, '
          'atención al cliente e información sobre nuestros productos.\n\n'
          '2. Uso de la Información: Tus datos de contacto y dirección de '
          'residencia se mantendrán seguros bajo nuestros protocolos de '
          'almacenamiento y no serán compartidos con terceros sin tu '
          'consentimiento.\n\n'
          '3. Compromiso del Usuario: Te comprometes a hacer un uso adecuado '
          'de la plataforma, a suministrar información veraz y a respetar las '
          'condiciones de compra y entrega de la distribuidora.',
          style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            'Cerrar',
            style: TextStyle(
              color: Color(0xFF00A8FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Casilla "Acepto los Términos, Políticas y Condiciones..." con enlace
/// subrayado que abre el diálogo.
class TerminosCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TerminosCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TerminosCheckbox> createState() => _TerminosCheckboxState();
}

class _TerminosCheckboxState extends State<TerminosCheckbox> {
  late final TapGestureRecognizer _tap;

  @override
  void initState() {
    super.initState();
    _tap = TapGestureRecognizer()..onTap = () => mostrarTerminos(context);
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: widget.value,
          onChanged: (v) => widget.onChanged(v ?? false),
          activeColor: const Color(0xFF00A8FF),
          checkColor: Colors.white,
          side: const BorderSide(color: Color(0xFF00A8FF), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Georgia',
                color: Colors.white,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'Acepto los '),
                TextSpan(
                  text: 'Términos, Políticas y Condiciones de '
                      'tratamiento de datos.',
                  style: const TextStyle(
                    color: Color(0xFF00A8FF),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF00A8FF),
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: _tap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
