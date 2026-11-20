import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  // URL base del backend en Render. Debe terminar en /api
  static const String _baseUrl = 'https://distribuidora-anita.onrender.com/api';

  static const String _keyTelefono = 'contacto_telefono';
  static const String _keyDireccion = 'contacto_direccion';

  static const String _telefonoPorDefecto = '322 732 8596';
  static const String _direccionPorDefecto = 'Calle 4 A Sur #16-05';

  static Map<String, String>? _cache;

  /// Lee del servidor. Si falla (sin internet), usa la última copia guardada.
  static Future<Map<String, String>> _cargar() async {
    if (_cache != null) return _cache!;

    final prefs = await SharedPreferences.getInstance();
    try {
      // El plan gratuito de Render se "duerme": la primera petición puede
      // tardar, por eso el tiempo de espera es de 30 segundos.
      final r = await http
          .get(Uri.parse('$_baseUrl/configuracion'))
          .timeout(const Duration(seconds: 30));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        final datos = {
          'telefono': (d['telefono'] ?? _telefonoPorDefecto).toString(),
          'direccion': (d['direccion'] ?? _direccionPorDefecto).toString(),
        };
        // copia local solo como respaldo sin internet
        await prefs.setString(_keyTelefono, datos['telefono']!);
        await prefs.setString(_keyDireccion, datos['direccion']!);
        _cache = datos;
        return datos;
      }
    } catch (_) {}

    return {
      'telefono': prefs.getString(_keyTelefono) ?? _telefonoPorDefecto,
      'direccion': prefs.getString(_keyDireccion) ?? _direccionPorDefecto,
    };
  }

  static Future<String> getTelefono() async => (await _cargar())['telefono']!;

  static Future<String> getDireccion() async =>
      (await _cargar())['direccion']!;

  /// Guarda en el servidor. Solo funciona con token de administrador.
  static Future<void> guardarContacto(
    String telefono,
    String direccion,
    String token,
  ) async {
    final r = await http
        .put(
          Uri.parse('$_baseUrl/configuracion'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'telefono': telefono, 'direccion': direccion}),
        )
        .timeout(const Duration(seconds: 30));

    if (r.statusCode != 200) {
      throw Exception('No se pudo guardar (${r.statusCode})');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTelefono, telefono);
    await prefs.setString(_keyDireccion, direccion);
    _cache = {'telefono': telefono, 'direccion': direccion};
  }

  /// Llama esto si quieres forzar volver a leer del servidor.
  static void limpiarCache() => _cache = null;
}