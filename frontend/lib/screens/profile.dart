import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/components/chat_distribuidora_modal.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();

  final _fNombre = FocusNode();
  final _fCorreo = FocusNode();
  final _fTelefono = FocusNode();
  final _fDireccion = FocusNode();

  final img_picker.ImagePicker _picker = img_picker.ImagePicker();

  img_picker.XFile? _fotoNueva;
  String? _fotoGuardada;
  bool _cargando = false;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosServidor();
  }

  // Carga los datos frescos directamente del backend (y de respaldo usa local)
  Future<void> _cargarDatosServidor() async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/profile');
      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usuario = data['usuario'] ?? data;
        
        setState(() {
          _nombre.text = usuario['nombre'] ?? '';
          _correo.text = usuario['correo'] ?? '';
          _telefono.text = usuario['telefono'] ?? '';
          _direccion.text = usuario['direccion'] ?? '';
          _fotoGuardada = usuario['avatar'] ?? usuario['foto_perfil'];
        });
      } else {
        // Respaldo con SharedPreferences si la red falla
        final datosLocales = await AuthService.getUsuario();
        setState(() {
          _nombre.text = datosLocales['nombre'] ?? '';
          _correo.text = datosLocales['correo'] ?? '';
          _telefono.text = datosLocales['telefono'] ?? '';
          _direccion.text = datosLocales['direccion'] ?? '';
          _fotoGuardada = datosLocales['foto'];
        });
      }
    } catch (e) {
      // Respaldo local si ocurre cualquier excepción
      final datosLocales = await AuthService.getUsuario();
      setState(() {
        _nombre.text = datosLocales['nombre'] ?? '';
        _correo.text = datosLocales['correo'] ?? '';
        _telefono.text = datosLocales['telefono'] ?? '';
        _direccion.text = datosLocales['direccion'] ?? '';
        _fotoGuardada = datosLocales['foto'];
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);
    try {
      String? fotoB64;
      if (_fotoNueva != null) {
        final bytes = await _fotoNueva!.readAsBytes();
        fotoB64 = base64Encode(bytes);
      }

      await AuthService.actualizarPerfil(
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
        telefono: _telefono.text.trim(),
        direccion: _direccion.text.trim(),
        fotoBase64: fotoB64,
      );

      if (!mounted) return;
      setState(() {
        _editando = false;
        if (fotoB64 != null) {
          _fotoGuardada = fotoB64;
          _fotoNueva = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      try {
        await AuthService.logout();
      } catch (_) {}
    } catch (_) {}

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _fNombre.dispose();
    _fCorreo.dispose();
    _fTelefono.dispose();
    _fDireccion.dispose();
    super.dispose();
  }

  void _activar(FocusNode fn) {
    setState(() => _editando = true);
    fn.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A8FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ProfileAvatar(
                    fotoNueva: _fotoNueva,
                    fotoGuardada: _fotoGuardada,
                    onTap: () async {
                      final img = await _picker.pickImage(
                        source: img_picker.ImageSource.gallery,
                        maxWidth: 400,
                        maxHeight: 400,
                        imageQuality: 35,
                      );
                      if (img != null) {
                        setState(() {
                          _fotoNueva = img;
                          _editando = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mi Perfil',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF084B75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00A8FF), width: 2),
                    ),
                    child: Column(
                      children: [
                        CampoEditable(
                          hint: 'Nombre',
                          controller: _nombre,
                          focusNode: _fNombre,
                          onEdit: () => _activar(_fNombre),
                          onChanged: () => setState(() => _editando = true),
                        ),
                        CampoEditable(
                          hint: 'Correo',
                          controller: _correo,
                          focusNode: _fCorreo,
                          tipo: TextInputType.emailAddress,
                          onEdit: () => _activar(_fCorreo),
                          onChanged: () => setState(() => _editando = true),
                        ),
                        CampoEditable(
                          hint: 'Teléfono',
                          controller: _telefono,
                          focusNode: _fTelefono,
                          tipo: TextInputType.phone,
                          onEdit: () => _activar(_fTelefono),
                          onChanged: () => setState(() => _editando = true),
                        ),
                        CampoEditable(
                          hint: 'Dirección',
                          controller: _direccion,
                          focusNode: _fDireccion,
                          onEdit: () => _activar(_fDireccion),
                          onChanged: () => setState(() => _editando = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      if (_editando) BotonGuardar(onPressed: _guardarCambios),
                      if (_editando) const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _cerrarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A74C0),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cerrar sesión', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
      floatingActionButton: ChatFab(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ChatDistribuidoraModal(),
        ),
      ),
    );
  }
}