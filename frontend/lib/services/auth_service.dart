import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ==========================
  // GUARDAR SESIÓN LOCAL
  // ==========================
  static Future<void> _guardarSesion(
    String token,
    Map<String, dynamic> usuario,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('usuario', jsonEncode(usuario));
  }

  // ==========================
  // LOGIN TRADICIONAL
  // ==========================
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
      if (data['token'] != null && data['usuario'] != null) {
        await _guardarSesion(data['token'], data['usuario']);
      }
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al iniciar sesión',
      );
    }
  }

  // ==========================
  // REGISTRO
  // ==========================
  Future<Map<String, dynamic>> registrar({
    required String nombre,
    required String correo,
    required String direccion,
    required String telefono,
    required String password,
    String? fotoBase64,
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
        'avatar': fotoBase64,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['token'] != null && data['usuario'] != null) {
        await _guardarSesion(data['token'], data['usuario']);
      }
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al registrar el usuario',
      );
    }
  }

  // ==========================
  // PERFIL Y SESIÓN LOCAL (Con mapeo exhaustivo de la foto)
  // ==========================
  static Future<Map<String, dynamic>> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString('usuario');

    if (usuarioString != null && usuarioString.isNotEmpty) {
      try {
        final Map<String, dynamic> usuarioMap = jsonDecode(usuarioString);

        // Si el JSON está vacío o no tiene un correo válido, limpiamos el caché fantasma
        if (usuarioMap.isEmpty ||
            (usuarioMap['correo'] == null && usuarioMap['nombre'] == null)) {
          await prefs.clear();
          return {};
        }

        return {
          'nombre': usuarioMap['nombre'] ?? '',
          'correo': usuarioMap['correo'] ?? '',
          'telefono': usuarioMap['telefono'] ?? '',
          'direccion': usuarioMap['direccion'] ?? '',
          // Buscamos en todas las variantes posibles para que nunca llegue vacía
          'foto': usuarioMap['foto_perfil'] ?? usuarioMap['avatar'] ?? usuarioMap['foto'] ?? '',
        };
      } catch (e) {
        await prefs.clear();
        return {};
      }
    }
    return {};
  }

  static Future<void> actualizarPerfil({
    required String nombre,
    required String correo,
    required String telefono,
    required String direccion,
    String? fotoBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioString = prefs.getString('usuario');

    if (usuarioString == null) throw Exception('No hay sesión activa');

    final Map<String, dynamic> usuarioMap = jsonDecode(usuarioString);

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/profile');

    final response = await http.put(
      url,
      headers: {
        ...ApiConfig.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'avatar': fotoBase64,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuarioActualizado =
          data['usuario'] ??
          {
            ...usuarioMap,
            'nombre': nombre,
            'correo': correo,
            'telefono': telefono,
            'direccion': direccion,
            if (fotoBase64 != null) 'avatar': fotoBase64,
          };
      await _guardarSesion(token ?? '', usuarioActualizado);
    } else {
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        throw Exception('Error del servidor (Ruta no encontrada o error 500)');
      }
      final data = jsonDecode(response.body);
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al actualizar perfil',
      );
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  // ==========================
  // GOOGLE SIGN-IN SIMPLIFICADO
  // ==========================
  Future<Map<String, dynamic>> loginConGoogle() async {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesión con Google cancelado');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String idToken =
        googleAuth.idToken ??
        googleAuth.accessToken ??
        'token_alternativo_google';

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/google');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'idToken': idToken,
        'correo': googleUser.email,
        'nombre': googleUser.displayName,
        'avatar': googleUser.photoUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['token'] != null && data['usuario'] != null) {
        await _guardarSesion(data['token'], data['usuario']);
      }
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al autenticar con Google',
      );
    }
  }
}