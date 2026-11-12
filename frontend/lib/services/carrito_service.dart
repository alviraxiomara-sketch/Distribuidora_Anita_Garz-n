import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class NoSesionException implements Exception {
  final String message;
  NoSesionException(this.message);
}

class CarritoService {
  static const Duration _tiempoEspera = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw NoSesionException('Debes iniciar sesión para realizar esta acción');
    }

    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  // Saca el mensaje de error del servidor aunque la respuesta no sea JSON
  static String _mensajeError(http.Response response, String porDefecto) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        return (data['error'] ?? data['mensaje'] ?? porDefecto).toString();
      }
    } catch (_) {}
    return '$porDefecto (código ${response.statusCode})';
  }

  // 1. Obtener los productos del carrito
  static Future<Map<String, dynamic>> obtenerCarrito() async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito');

    final response = await http
        .get(url, headers: headers)
        .timeout(_tiempoEspera);
    debugPrint('CARRITO GET -> ${response.statusCode} | ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map) return Map<String, dynamic>.from(data);
      throw Exception('Respuesta inesperada al obtener el carrito');
    }
    throw Exception(_mensajeError(response, 'Error al obtener el carrito'));
  }

  // 2. Agregar un producto al carrito
  static Future<void> agregarAlCarrito({
    required dynamic idProducto,
    required int cantidad,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito');

    final response = await http
        .post(
          url,
          headers: headers,
          body: jsonEncode({'id_producto': idProducto, 'cantidad': cantidad}),
        )
        .timeout(_tiempoEspera);
    debugPrint('CARRITO POST -> ${response.statusCode} | ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_mensajeError(response, 'Error al agregar al carrito'));
    }
  }

  // 3. Actualizar la cantidad de un detalle existente
  static Future<void> actualizarCantidad(int idDetalle, int cantidad) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito/actualizar/$idDetalle');

    final response = await http
        .put(url, headers: headers, body: jsonEncode({'cantidad': cantidad}))
        .timeout(_tiempoEspera);
    debugPrint('CARRITO PUT -> ${response.statusCode} | ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response, 'Error al actualizar cantidad'));
    }
  }

  // 4. Eliminar un producto del carrito
  static Future<void> eliminarDetalle(int idDetalle) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito/eliminar/$idDetalle');

    final response = await http
        .delete(url, headers: headers)
        .timeout(_tiempoEspera);
    debugPrint('CARRITO DELETE -> ${response.statusCode} | ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response, 'Error al eliminar del carrito'));
    }
  }
}
