import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_config.dart';

class ProductoFormControllerHelper {
  static Future<void> guardarProducto({
    required BuildContext context,
    required TextEditingController nombreController,
    required TextEditingController valorController,
    required TextEditingController precioMayoristaController,
    required TextEditingController presentacionController,
    required TextEditingController cantidadController,
    required TextEditingController cantidadMinimaMayoristaController,
    required TextEditingController descripcionController,
    required int? categoriaSeleccionadaId,
    required img_picker.XFile? imagenProducto,
    required VoidCallback onExito,
    required ValueChanged<bool> onCargando,
  }) async {
    if (nombreController.text.trim().isEmpty || 
        valorController.text.trim().isEmpty || 
        categoriaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena los campos obligatorios y la categoría'), backgroundColor: Colors.orange),
      );
      return;
    }

    onCargando(true);
    try {
      final token = (await SharedPreferences.getInstance()).getString('token');
      final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/productos'));

      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll({
        'id_categoria': categoriaSeleccionadaId.toString(),
        'nombre': nombreController.text.trim(),
        'precio_detal': valorController.text.trim(),
        'precio_mayorista': precioMayoristaController.text.trim(),
        'presentacion': presentacionController.text.trim(),
        'cantidad': cantidadController.text.trim().isEmpty ? '0' : cantidadController.text.trim(),
        'cantidad_minima_mayorista': cantidadMinimaMayoristaController.text.trim().isEmpty ? '0' : cantidadMinimaMayoristaController.text.trim(),
        'descripcion': descripcionController.text.trim(),
      });

      if (imagenProducto != null) {
        request.files.add(kIsWeb
            ? http.MultipartFile.fromBytes('imagen', await imagenProducto.readAsBytes(), filename: imagenProducto.name)
            : await http.MultipartFile.fromPath('imagen', imagenProducto.path));
      }

      final res = await http.Response.fromStream(await request.send());
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Producto registrado con éxito!'), backgroundColor: Colors.green),
        );
        [nombreController, valorController, precioMayoristaController, presentacionController, cantidadController, cantidadMinimaMayoristaController, descripcionController].forEach((c) => c.clear());
        onExito();
      } else {
        throw Exception(jsonDecode(res.body)['error'] ?? 'Error al registrar');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      onCargando(false);
    }
  }
}