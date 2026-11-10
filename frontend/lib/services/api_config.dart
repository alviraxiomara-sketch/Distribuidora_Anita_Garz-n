import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Mantenemos en 'true' para que apunte a tu backend en Render
  static const bool useRemoteServer = true;
  static const String _remoteUrl =
      'https://distribuidora-anita.onrender.com/api';

  static String get baseUrl {
    // Como está en true, siempre usará la URL de Render
    if (useRemoteServer) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}