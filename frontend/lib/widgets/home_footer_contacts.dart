import 'package:flutter/material.dart';
import 'package:frontend/services/config_service.dart';

class HomeFooterContacts extends StatefulWidget {
  final bool isAdmin;

  const HomeFooterContacts({super.key, this.isAdmin = false});

  @override
  State<HomeFooterContacts> createState() => _HomeFooterContactsState();
}

class _HomeFooterContactsState extends State<HomeFooterContacts> {
  String _telefono = '322 732 8596';
  String _direccion = 'Calle 4 A Sur #16-05';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final tel = await ConfigService.getTelefono();
    final dir = await ConfigService.getDireccion();
    if (mounted) {
      setState(() {
        _telefono = tel;
        _direccion = dir;
      });
    }
  }

  void _mostrarDialogoEditar() {
    final telController = TextEditingController(text: _telefono);
    final dirController = TextEditingController(text: _direccion);

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF063B5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00A8FF), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: Color(0xFF00A8FF), size: 24),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Editar Contacto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actualiza la información de atención al cliente visible en toda la aplicación.',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12.5, height: 1.3),
              ),
              const SizedBox(height: 20),
              const Text(
                'Teléfono',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: telController,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ingrese el teléfono',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF063B5D), size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00A8FF), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dirección',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: dirController,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ingrese la dirección',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00A8FF), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await ConfigService.guardarContacto(telController.text.trim(), dirController.text.trim());
              await _cargarDatos();
              if (!context.mounted) return;
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Datos de contacto actualizados con éxito!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF063B5D),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.headset_mic_rounded, color: Color(0xFF00A8FF), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Servicios de Atención',
                    style: TextStyle(
                      color: Color(0xFF00A8FF),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
              if (widget.isAdmin)
                IconButton(
                  onPressed: _mostrarDialogoEditar,
                  icon: const Icon(Icons.edit, color: Color(0xFF00A8FF), size: 20),
                  tooltip: 'Editar información',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF031A2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone, color: Color(0xFF00A8FF), size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _telefono,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF031A2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _direccion,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}