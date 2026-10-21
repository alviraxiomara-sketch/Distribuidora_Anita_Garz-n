import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class NoSesionException implements Exception {
  final String message;
  NoSesionException(this.message);
}

class CarritoService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw NoSesionException('Debes iniciar sesión para realizar esta acción');
    }

    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Obtener los productos del carrito desde el backend
  static Future<Map<String, dynamic>> obtenerCarrito() async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito');

    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Error al obtener el carrito');
    }
  }

  // 2. Agregar un producto al carrito
  static Future<void> agregarAlCarrito({
    required dynamic idProducto,
    required int cantidad,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito/agregar');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'id_producto': idProducto,
        'cantidad': cantidad,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al agregar al carrito');
    }
  }

  // 3. Actualizar la cantidad de un detalle existente
  static Future<void> actualizarCantidad(int idDetalle, int cantidad) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito/actualizar/$idDetalle');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'cantidad': cantidad}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al actualizar cantidad');
    }
  }

  // 4. Eliminar un producto del carrito
  static Future<void> eliminarDetalle(int idDetalle) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/carrito/eliminar/$idDetalle');

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al eliminar del carrito');
    }
  }
}