import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'correo': correo,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // Devuelve el token JWT y los datos del usuario
    } else {
      // Captura el mensaje del campo 'error' de tu controller de Node.js
      throw Exception(data['error'] ?? 'Error al iniciar sesión');
    }
  }
}