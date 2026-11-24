import 'package:flutter/material.dart';
import '../services/chatdistribuidora.dart';
import '../widgets/mensaje_bot.dart';

/// Pantalla del chat de Distribuidora Anita.
/// Usa ChatDistribuidoraService (chatdistribuidora.dart) y MensajeBot (mensaje_bot.dart).
///
/// Cómo abrirla:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => PantallaChat(usuarioId: idDelUsuario),
///   ));
class PantallaChat extends StatefulWidget {
  final String? sesionId; // opcional: para recuperar un historial anterior
  final int? usuarioId; // opcional: id_usuario del cliente logueado

  const PantallaChat({super.key, this.sesionId, this.usuarioId});

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final TextEditingController _controlador = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _mensajes = [];

  String? _sesionId;
  bool _enviando = false;
  bool _cargandoHistorial = false;

  static const Color _colorPrincipal = Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    _sesionId = widget.sesionId;

    // Despierta el servidor de Render apenas se abre el chat
    ChatDistribuidoraService.despertarServidor();

    if (_sesionId != null) {
      _cargarHistorial();
    } else {
      _mensajes.add({
        'role': 'bot',
        'text': '¡Hola! Bienvenido a Distribuidora Anita 🥤. '
            '¿En qué antojo refrescante te podemos colaborar hoy?',
      });
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _cargandoHistorial = true);
    final historial =
        await ChatDistribuidoraService.obtenerHistorial(_sesionId!);
    if (!mounted) return;
    setState(() {
      _mensajes.addAll(historial);
      _cargandoHistorial = false;
    });
    _bajarAlFinal();
  }

  void _bajarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar([String? textoRapido]) async {
    final texto = (textoRapido ?? _controlador.text).trim();
    if (texto.isEmpty || _enviando) return;

    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _enviando = true;
    });
    _controlador.clear();
    _bajarAlFinal();

    final resultado = await ChatDistribuidoraService.enviarMensaje(
      texto,
      sesionId: _sesionId,
      usuarioId: widget.usuarioId,
    );

    if (!mounted) return;
    setState(() {
      _sesionId = resultado['sesionId'] as String? ?? _sesionId;
      _mensajes.add({
        'role': 'bot',
        'text': (resultado['respuesta'] ?? '').toString(),
      });
      _enviando = false;
    });
    _bajarAlFinal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _colorPrincipal,
        foregroundColor: Colors.black87,
        title: const Text('Chat Distribuidora Anita'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cargandoHistorial
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _mensajes.length + (_enviando ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _mensajes.length) return _burbujaEscribiendo();
                      return _burbuja(_mensajes[i]);
                    },
                  ),
          ),
          _sugerencias(),
          _barraEscribir(),
        ],
      ),
    );
  }

  Widget _burbuja(Map<String, String> msg) {
    final esUsuario = msg['role'] == 'user';
    final ancho = MediaQuery.of(context).size.width;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(maxWidth: ancho * 0.88),
        decoration: BoxDecoration(
          color: esUsuario ? _colorPrincipal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(esUsuario ? 14 : 2),
            bottomRight: Radius.circular(esUsuario ? 2 : 14),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: esUsuario
            ? Text(
                msg['text'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              )
            : MensajeBot(texto: msg['text'] ?? ''),
      ),
    );
  }

  Widget _burbujaEscribiendo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _sugerencias() {
    const opciones = ['Ver catálogo', 'Cervezas', 'Importadas', 'Envíos'];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(opciones[i]),
          backgroundColor: Colors.white,
          onPressed: _enviando ? null : () => _enviar(opciones[i]),
        ),
      ),
    );
  }

  Widget _barraEscribir() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controlador,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: _colorPrincipal),
              onPressed: _enviando ? null : () => _enviar(),
              icon: const Icon(Icons.send, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}