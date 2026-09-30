import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. Constantes y Colores Globales
// ---------------------------------------------------------------------------
const Color kFondoOscuro = Color(0xFF0B2033);
const Color kAzulTarjeta = Color(0xFF13355A);
const Color kAzulBorde = Color(0xFF3DA5F5);
const Color kAzulBoton = Color(0xFF2E86DE);
const Color kCampoRelleno = Color(0xFFE9EDF1);
const Color kTextoClaro = Colors.white;

class AppColors {
  static const Color primary = kFondoOscuro;
  static const Color accent = kAzulBorde;
  static const Color textLight = kTextoClaro;
  static const Color textMuted = Colors.white70;
  static const Color inputFill = kCampoRelleno;
  static const Color facebookBlue = Color(0xFF1877F2);
}

// ---------------------------------------------------------------------------
// 2. Estilos de Texto
// ---------------------------------------------------------------------------
const TextStyle kTituloScreen = TextStyle(
  color: kTextoClaro,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

const TextStyle kSubtitulo = TextStyle(
  color: kTextoClaro,
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

const TextStyle kEtiquetaCampo = TextStyle(color: kTextoClaro, fontSize: 13);

class AppTextStyles {
  static const TextStyle titulo = TextStyle(
    color: AppColors.textLight,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitulo = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle categoriaLabel = TextStyle(
    color: AppColors.textLight,
    fontSize: 11,
  );
}

// ---------------------------------------------------------------------------
// 3. Helpers y Funciones Reutilizables
// ---------------------------------------------------------------------------
InputDecoration campoDecoration(String hint, {Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: kCampoRelleno,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

ButtonStyle botonPrincipalStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: kAzulBoton,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 42),
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

BoxDecoration tarjetaDecoration() {
  return BoxDecoration(
    color: kAzulTarjeta,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: kAzulBorde, width: 1.5),
  );
}

// ---------------------------------------------------------------------------
// 4. ThemeData global
// ---------------------------------------------------------------------------
final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: kFondoOscuro,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kAzulBoton,
    brightness: Brightness.dark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: botonPrincipalStyle()),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: kAzulBorde),
      minimumSize: const Size(double.infinity, 38),
    ),
  ),
);
