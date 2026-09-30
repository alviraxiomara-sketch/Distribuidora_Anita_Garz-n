import 'package:flutter/material.dart';

const kBg = Color(0xFF0B2F55);
const kBar = Color(0xFF14497E);
const kPanel = Color(0xFF1B4F80);
const kAccent = Color(0xFF1E88E5);
const kField = Color(0xFFD9D9D9);

ThemeData appTheme() => ThemeData(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kAccent),
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Serif'),
    );

/// Scaffold con barra azul superior: iconos a la izquierda, centro opcional y derecha.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> left;
  final List<Widget> right;
  final Widget? center;
  final Widget? fab;
  final FloatingActionButtonLocation? fabLocation;
  const AppScaffold({
    super.key,
    required this.body,
    this.left = const [],
    this.right = const [],
    this.center,
    this.fab,
    this.fabLocation,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: kBar,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: 44.0 * left.length + 8,
          leading: Row(children: left),
          title: center,
          actions: right,
        ),
        floatingActionButton: fab,
        floatingActionButtonLocation: fabLocation,
        body: SafeArea(child: body),
      );
}

IconButton _nav(BuildContext c, IconData i, String route, {Color? color}) =>
    IconButton(
        visualDensity: VisualDensity.compact,
        icon: Icon(i, color: color),
        onPressed: () => Navigator.pushNamed(c, route));

IconButton navHome(BuildContext c) => _nav(c, Icons.home_outlined, '/home');
IconButton navBell(BuildContext c) => _nav(c, Icons.notifications_none, '/notificaciones');
IconButton navCart(BuildContext c) => _nav(c, Icons.shopping_cart_outlined, '/carrito');
IconButton navProfile(BuildContext c) => _nav(c, Icons.account_circle_outlined, '/perfil');
IconButton navStock(BuildContext c) =>
    _nav(c, Icons.inventory_2, '/stock', color: Colors.orange);

/// Avatar circular del asistente de IA (botón flotante en varias pantallas).
class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/ia'),
        child: const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(Icons.smart_toy, color: kBar),
        ),
      );
}

/// Contenedor con borde azul brillante y esquinas redondeadas.
class BorderPanel extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;
  const BorderPanel(
      {super.key, this.title, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: padding,
        decoration: BoxDecoration(
          color: kPanel.withOpacity(.35),
          border: Border.all(color: kAccent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (title != null) ...[
            Text(title!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          child,
        ]),
      );
}

/// Campo de texto gris redondeado.
class GrayField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? type;
  const GrayField(this.hint,
      {super.key, this.obscure = false, this.controller, this.type});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          style: const TextStyle(color: Colors.black, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
            isDense: true,
            filled: true,
            fillColor: kField,
            suffixIcon: obscure
                ? const Icon(Icons.visibility_outlined, size: 18, color: Colors.black54)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
          ),
        ),
      );
}

/// Botón azul pequeño.
class BlueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const BlueButton(this.label, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(110, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
}

/// Tarjeta de producto con imagen, nombre, precio y acciones a la derecha.
class ProductCard extends StatelessWidget {
  final String name, price, unit;
  final Widget? trailing;
  final Color? color;
  const ProductCard(
      {super.key,
      required this.name,
      required this.price,
      this.unit = '',
      this.trailing,
      this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? kPanel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.local_drink, size: 30),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(fontSize: 11)),
              if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 11)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Selector de cantidad  [ - 1 + ].
class QtyStepper extends StatefulWidget {
  const QtyStepper({super.key});
  @override
  State<QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<QtyStepper> {
  int q = 1;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: kAccent, borderRadius: BorderRadius.circular(4)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _b(Icons.remove, () => setState(() => q = q > 1 ? q - 1 : 1)),
          Text('$q', style: const TextStyle(fontSize: 12)),
          _b(Icons.add, () => setState(() => q++)),
        ]),
      );

  Widget _b(IconData i, VoidCallback f) => InkWell(
      onTap: f,
      child: Padding(padding: const EdgeInsets.all(4), child: Icon(i, size: 14)));
}