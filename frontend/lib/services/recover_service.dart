import 'dart:convert';
import 'package:frontend/services/api_config.dart';
import 'package:http/http.dart' as http;

class RecoverService {
  Future<Map<String, dynamic>> solicitarRecuperacion({
    required String correo,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recuperar/forgot-password');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({'correo': correo}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al enviar el código',
      );
    }
  }

  Future<Map<String, dynamic>> cambiarContrasenaConCodigo({
    required String correo,
    required String codigo,
    required String nuevaPassword,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recuperar/reset-password');

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'correo': correo,
        'codigo': codigo,
        'passwordNueva': nuevaPassword, // Coincide exactamente con el backend
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'Error al cambiar la contraseña',
      );
    }
  }
}