import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Cambia a 'false' si en algún momento quieres usar tu servidor local en la PC
  static const bool useRemoteServer = true;
  static const String _remoteUrl =
      'https://distribuidora-anita.onrender.com/api';

  static String get baseUrl {
    // Si el servidor remoto de Render está activado
    if (useRemoteServer) {
      return _remoteUrl;
    }

    // Si estás ejecutando en Web (local)
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Si estás usando el emulador de Android (10.0.2.2 apunta al localhost de tu PC)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';

      // NOTA: Si pruebas en un celular físico por Wi-Fi, comenta la línea de arriba
      // y descomenta la siguiente poniendo la IP local de tu PC (ej: 'http://192.168.1.X:3000/api')
      // return 'http://TU_IP_LOCAL:3000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api';
    }

    // Fallback para Desktop (Windows, macOS, Linux)
    return 'http://localhost:3000/api';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
