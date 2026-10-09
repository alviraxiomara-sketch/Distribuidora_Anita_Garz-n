import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  // Obtener datos del usuario guardados localmente
  static Future<Map<String, String?>> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombre': prefs.getString('nombre'),
      'correo': prefs.getString('correo'),
      'telefono': prefs.getString('telefono'),
      'direccion': prefs.getString('direccion'),
      'foto': prefs.getString('foto'),
    };
  }

  // Cerrar sesión y limpiar TODOS los datos almacenados localmente
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Método para Iniciar Sesión y Guardar Datos Localmente
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({'correo': correo, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiamos los datos del usuario anterior
      await prefs.clear();

      final usuario = data['usuario'] ?? data['user'] ?? data;

      await prefs.setString('nombre', usuario['nombre'] ?? '');
      await prefs.setString('correo', usuario['correo'] ?? correo);
      await prefs.setString('telefono', usuario['telefono'] ?? '');
      await prefs.setString('direccion', usuario['direccion'] ?? '');

      // Guardamos la foto del usuario recibida desde Supabase
      final fotoUsuario = usuario['foto_perfil'] ?? usuario['foto'];
      if (fotoUsuario != null && fotoUsuario.toString().isNotEmpty) {
        await prefs.setString('foto', fotoUsuario);
      } else {
        await prefs.remove('foto');
      }

      if (data['token'] != null) {
        await prefs.setString('token', data['token']);
      }

      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al iniciar sesión',
      );
    }
  }

  // Método para Registrar Usuario
  Future<Map<String, dynamic>> registrar({
    required String nombre,
    required String correo,
    required String direccion,
    required String telefono,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'direccion': direccion,
        'telefono': telefono,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await prefs.setString('nombre', nombre);
      await prefs.setString('correo', correo);
      await prefs.setString('telefono', telefono);
      await prefs.setString('direccion', direccion);
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al registrar usuario',
      );
    }
  }

  // Actualizar Perfil en Backend y Localmente
  static Future<void> actualizarPerfil({
    required String nombre,
    required String correo,
    required String telefono,
    required String direccion,
    String? fotoBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/profile');

    final Map<String, dynamic> bodyData = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
    };

    if (fotoBase64 != null) {
      bodyData['foto'] = fotoBase64;
      bodyData['foto_perfil'] = fotoBase64;
    }

    final response = await http.put(
      url,
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await prefs.setString('nombre', nombre);
      await prefs.setString('correo', correo);
      await prefs.setString('telefono', telefono);
      await prefs.setString('direccion', direccion);
      if (fotoBase64 != null) {
        await prefs.setString('foto', fotoBase64);
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['error'] ?? data['mensaje'] ?? 'Error al actualizar perfil',
        );
      } catch (e) {
        throw Exception(
          'Error en el servidor (${response.statusCode}). Revisa que el backend esté corriendo.',
        );
      }
    }
  }
}