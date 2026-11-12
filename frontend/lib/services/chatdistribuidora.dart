import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatDistribuidoraService {
  static String get _chatUrl => '${ApiConfig.baseUrl}/chatbox';

  // Render (plan gratis) puede tardar ~30-60 s en despertar tras estar inactivo.
  static const int _intentos = 3;
  static const Duration _timeout = Duration(seconds: 45);

  /// Llamar al abrir el chat: "despierta" el servidor antes de que el cliente escriba.
  static Future<void> despertarServidor() async {
    try {
      await http
          .get(Uri.parse('$_chatUrl/salud'), headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      // Silencioso: es solo un "toque" para despertar el servidor
    }
  }

  static Future<Map<String, dynamic>> enviarMensaje(
    String mensaje, {
    String? sesionId,
    int? usuarioId,
  }) async {
    String? mensajeServidor;

    for (var intento = 1; intento <= _intentos; intento++) {
      try {
        final response = await http
            .post(
              Uri.parse(_chatUrl),
              headers: ApiConfig.headers,
              body: jsonEncode({
                'mensaje': mensaje,
                'sesionId': sesionId,
                'usuarioId': usuarioId,
              }),
            )
            .timeout(_timeout);

        final body = utf8.decode(response.bodyBytes);

        if (response.statusCode == 200) {
          final data = jsonDecode(body);
          return {
            'respuesta': data['respuesta'] ?? 'No se recibió respuesta.',
            'sesionId': data['sesionId'] ?? sesionId,
          };
        }

        // Guardamos el mensaje amable que mande el servidor (si lo hay)
        try {
          final data = jsonDecode(body);
          mensajeServidor = data['respuesta'] ?? data['message'];
        } catch (_) {}

        // Errores del cliente (400, 404...) no se arreglan reintentando
        final reintentable = response.statusCode >= 500 ||
            response.statusCode == 429 ||
            response.statusCode == 408;
        if (!reintentable) break;

        debugPrint('Chat: intento $intento falló con status ${response.statusCode}');
      } on TimeoutException {
        debugPrint('Chat: intento $intento agotó el tiempo de espera');
      } catch (e) {
        debugPrint('Chat: intento $intento error de red: $e');
      }

      if (intento < _intentos) {
        await Future.delayed(Duration(seconds: 2 * intento));
      }
    }

    return {
      'respuesta': mensajeServidor ??
          'No pudimos conectarnos con la distribuidora en este momento. '
              'Revisa tu internet e inténtalo de nuevo en unos segundos.',
      'sesionId': sesionId,
    };
  }

  // Cargar el historial cuando el usuario entra al chat
  static Future<List<Map<String, String>>> obtenerHistorial(String sesionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_chatUrl/historial/$sesionId'),
            headers: ApiConfig.headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List historialRaw = data['historial'] ?? [];

        return historialRaw.map<Map<String, String>>((item) {
          return {
            'role': item['emisor'] == 'user' ? 'user' : 'bot',
            'text': (item['mensaje'] ?? '').toString(),
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error al obtener historial: $e');
    }
    return [];
  }
}