import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatDistribuidoraService {
  // Concatena con la baseUrl de tu archivo api_config.dart
  static String get _chatUrl => '${ApiConfig.baseUrl}/chat-distribuidora';

  static Future<String> enviarMensaje(String mensaje, {String? sesionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId ?? 'cliente_distribuidora_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['respuesta'] ?? 'No se recibió respuesta.';
      } else {
        return 'En este momento no pudimos procesar tu solicitud.';
      }
    } catch (e) {
      return 'Error de conexión con la distribuidora. Revisa tu servidor.';
    }
  }
}