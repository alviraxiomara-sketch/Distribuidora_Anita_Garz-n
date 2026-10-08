import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatDistribuidoraService {
  // Se corrigió el nombre de la ruta a '/chatbox' para coincidir con tu router[cite: 22]
  static String get _chatUrl => '${ApiConfig.baseUrl}/chatbox';

  static Future<Map<String, dynamic>> enviarMensaje(
    String mensaje, {
    String? sesionId,
    int? usuarioId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: ApiConfig.headers, //[cite: 25]
        body: jsonEncode({
          'mensaje': mensaje, //
          'sesionId': sesionId, //
          'usuarioId': usuarioId, //
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'respuesta': data['respuesta'] ?? 'No se recibió respuesta.', //
          'sesionId': data['sesionId'], //[cite: 23]
        };
      } else {
        return {
          'respuesta': 'En este momento no pudimos procesar tu solicitud.',
          'sesionId': sesionId,
        };
      }
    } catch (e) {
      return {
        'respuesta': 'Error de conexión con la distribuidora. Revisa tu servidor.',
        'sesionId': sesionId,
      };
    }
  }

  // Método para cargar el historial cuando el usuario entra al chat
  static Future<List<Map<String, String>>> obtenerHistorial(String sesionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chatbox/historial/$sesionId'), //[cite: 22]
        headers: ApiConfig.headers, //[cite: 25]
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List historialRaw = data['historial'] ?? []; //[cite: 23]

        return historialRaw.map<Map<String, String>>((item) {
          return {
            'role': item['emisor'] == 'user' ? 'user' : 'bot', //[cite: 23]
            'text': item['mensaje'] ?? '', //[cite: 23]
          };
        }).toList();
      }
    } catch (e) {
      print('Error al obtener historial: $e');
    }
    return [];
  }
}