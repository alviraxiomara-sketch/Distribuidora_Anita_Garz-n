import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/principal_cliente.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/notificaciones_cliente.dart';
import 'package:frontend/screens/cart_screen.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/app_drawer.dart';
import 'package:frontend/widgets/checkout_form_fields.dart';
import 'package:frontend/widgets/checkout_nequi_section.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> productosSeleccionados;
  final double totalPagar;

  const CheckoutScreen({
    super.key,
    required this.productosSeleccionados,
    required this.totalPagar,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String? _metodoPago;
  File? _comprobanteImagen;
  Uint8List? _comprobanteBytes;
  bool _procesando = false;
  List<dynamic> _categoriasList = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final decoded = jsonDecode(res.body);
        setState(() {
          _categoriasList = decoded is List ? decoded : [];
        });
      }
    } catch (_) {}
  }

  Future<void> _seleccionarComprobante() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _comprobanteBytes = bytes;
        });
      } else {
        setState(() {
          _comprobanteImagen = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _realizarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_metodoPago == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione un método de pago'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_metodoPago == 'Nequi' && _comprobanteImagen == null && _comprobanteBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor adjunta el comprobante de pago de Nequi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('No has iniciado sesión');
      }

      String? comprobanteBase64;

      if (_metodoPago == 'Nequi') {
        if (kIsWeb && _comprobanteBytes != null) {
          comprobanteBase64 = 'data:image/jpeg;base64,${base64Encode(_comprobanteBytes!)}';
        } else if (_comprobanteImagen != null) {
          final bytes = await _comprobanteImagen!.readAsBytes();
          comprobanteBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/pedidos');
      
      final response = await http.post(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre_cliente': _nombreController.text,
          'direccion_entrega': _direccionController.text,
          'telefono_contacto': _telefonoController.text,
          'metodo_pago': _metodoPago,
          'comprobante_url': comprobanteBase64,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Pedido realizado con éxito y notificado al administrador!'),
            backgroundColor: Color(0xFF00A2E8),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
          (route) => false,
        );
      } else {
        throw Exception(responseData['error'] ?? 'Error al procesar el pedido');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063B5D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalClienteScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificacionesScreen()),
            ),
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: AppDrawer(categorias: _categoriasList),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalle del Pedido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.productosSeleccionados.length,
                itemBuilder: (context, index) {
                  final item = widget.productosSeleccionados[index];
                  final producto = item['productos'] ?? {};
                  final nombre = producto['nombre'] ?? 'Producto';
                  final presentacion = producto['presentacion'] ?? '';
                  final imagenUrl = producto['imagen_url'] ?? '';
                  final subtotal = item['subtotal'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF063B5D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00A2E8), width: 1),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imagenUrl.isNotEmpty
                              ? Image.network(imagenUrl, width: 50, height: 50, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.local_drink, color: Colors.white, size: 30))
                              : const Icon(Icons.local_drink, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('$presentacion', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text(
                          '\$$subtotal',
                          style: const TextStyle(color: Color(0xFF00A8FF), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // =========================================================================
              // NUEVA TARJETA: TOTAL A PAGAR DE LOS PRODUCTOS SELECCIONADOS
              // =========================================================================
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF063B5D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00A2E8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${widget.totalPagar}',
                      style: const TextStyle(
                        color: Color(0xFF00A8FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              CheckoutFormFields(
                nombreController: _nombreController,
                direccionController: _direccionController,
                telefonoController: _telefonoController,
                metodoPago: _metodoPago,
                onMetodoPagoChanged: (nuevoValor) {
                  setState(() {
                    _metodoPago = nuevoValor;
                  });
                },
              ),

              if (_metodoPago == 'Nequi')
                CheckoutNequiSection(
                  comprobanteImagen: _comprobanteImagen,
                  comprobanteBytes: _comprobanteBytes,
                  onSeleccionarComprobante: _seleccionarComprobante,
                ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _procesando ? null : _realizarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _procesando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Realizar Pedido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}