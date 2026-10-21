import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _keyTelefono = 'contacto_telefono';
  static const String _keyDireccion = 'contacto_direccion';

  static Future<String> getTelefono() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTelefono) ?? '322 732 8596';
  }

  static Future<String> getDireccion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDireccion) ?? 'Calle 4 A Sur #16-05';
  }

  static Future<void> guardarContacto(String telefono, String direccion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTelefono, telefono);
    await prefs.setString(_keyDireccion, direccion);
  }
}