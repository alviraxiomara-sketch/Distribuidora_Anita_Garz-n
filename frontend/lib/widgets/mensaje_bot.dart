import 'package:flutter/material.dart';

/// Muestra la respuesta del bot. Si el texto trae tablas en formato Markdown
/// (| Producto | Presentación | Precio |) las dibuja como tabla organizada;
/// el resto del texto se muestra normal. Colores pensados para el chat azul
/// oscuro de Distribuidora Anita.
class MensajeBot extends StatelessWidget {
  final String texto;
  final Color colorTexto;
  final Color colorEncabezado;
  final Color colorFilaA;
  final Color colorFilaB;
  final Color colorBorde;

  const MensajeBot({
    super.key,
    required this.texto,
    this.colorTexto = Colors.white,
    this.colorEncabezado = const Color(0xFF00A8FF),
    this.colorFilaA = const Color(0xFF063B5D),
    this.colorFilaB = const Color(0xFF032238),
    this.colorBorde = const Color(0xFF00A8FF),
  });

  bool _esFilaTabla(String linea) {
    final t = linea.trim();
    return t.length > 1 && t.startsWith('|') && t.endsWith('|');
  }

  bool _esSeparador(String linea) {
    final t = linea.trim();
    return t.contains('-') && RegExp(r'^\|?[\s:\-|]+\|?$').hasMatch(t);
  }

  List<String> _celdas(String linea) {
    final t = linea.trim();
    return t
        .substring(1, t.length - 1)
        .split('|')
        .map((c) => c.trim().replaceAll('**', ''))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final textoSuelto = <String>[];
    final filasTabla = <List<String>>[];

    void cerrarTexto() {
      final t = textoSuelto.join('\n').trim();
      if (t.isNotEmpty) {
        widgets.add(Text(t, style: TextStyle(fontSize: 14, color: colorTexto)));
      }
      textoSuelto.clear();
    }

    void cerrarTabla() {
      if (filasTabla.isNotEmpty) {
        widgets.add(_construirTabla(List.of(filasTabla)));
      }
      filasTabla.clear();
    }

    for (final linea in texto.split('\n')) {
      if (_esFilaTabla(linea)) {
        cerrarTexto();
        if (!_esSeparador(linea)) filasTabla.add(_celdas(linea));
      } else {
        cerrarTabla();
        textoSuelto.add(linea);
      }
    }
    cerrarTexto();
    cerrarTabla();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final w in widgets)
          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: w),
      ],
    );
  }

  Widget _construirTabla(List<List<String>> filas) {
    final columnas = filas.first.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: colorBorde.withOpacity(0.4)),
          children: [
            for (var i = 0; i < filas.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i == 0
                      ? colorEncabezado
                      : (i.isEven ? colorFilaB : colorFilaA),
                ),
                children: [
                  for (var c = 0; c < columnas; c++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        c < filas[i].length ? filas[i][c] : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorTexto,
                          fontWeight:
                              i == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}