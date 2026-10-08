// import 'package:flutter/material.dart';
// import 'core.dart';

// /// Home
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   static const cats = [
//     ('Gaseosas', Icons.local_drink),
//     ('Jugos', Icons.emoji_food_beverage),
//     ('Cervezas', Icons.sports_bar),
//     ('Aguas', Icons.water_drop),
//     ('Lacteos', Icons.icecream),
//     ('Energizantes', Icons.bolt),
//   ];

//   @override
//   Widget build(BuildContext context) => AppScaffold(
//         left: [navBell(context)],
//         right: [navCart(context), navProfile(context)],
//         fab: const AiAvatar(),
//         body: SingleChildScrollView(
//           child: Column(children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(children: [
//                 const CircleAvatar(
//                     radius: 34,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.local_bar, size: 34, color: kBar)),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Text(
//                     'Bienvenidos a distribuidora de bebidas Anita\n'
//                     'Tu mejor opción en pedidos y distribuciones de bebidas',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
//                   ),
//                 ),
//               ]),
//             ),
//             const Text('¡Estamos listos para atenderte!', style: TextStyle(fontSize: 13)),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               color: kBar,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: const Text('Categorías',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             GridView.count(
//               crossAxisCount: 3,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: const EdgeInsets.all(16),
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               children: [
//                 for (final c in cats)
//                   GestureDetector(
//                     onTap: () => Navigator.pushNamed(context, '/productos', arguments: c.$1),
//                     child: Column(children: [
//                       Container(
//                         width: 64,
//                         height: 64,
//                         decoration: BoxDecoration(
//                             color: Colors.white, borderRadius: BorderRadius.circular(6)),
//                         child: Icon(c.$2, size: 36, color: kBar),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(c.$1, style: const TextStyle(fontSize: 10)),
//                     ]),
//                   ),
//               ],
//             ),
//             Container(
//               width: double.infinity,
//               color: kBar,
//               padding: const EdgeInsets.all(16),
//               child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Contáctanos', style: TextStyle(fontSize: 11)),
//                 SizedBox(height: 6),
//                 Row(children: [Icon(Icons.phone, size: 14), SizedBox(width: 6),
//                   Text('3227328596', style: TextStyle(fontSize: 10))]),
//                 Row(children: [Icon(Icons.place, size: 14, color: Colors.red), SizedBox(width: 6),
//                   Text('calle 4 a sur #16-05', style: TextStyle(fontSize: 10))]),
//               ]),
//             ),
//           ]),
//         ),
//       );
// }

// /// Listado de productos por categoría
// class ProductListScreen extends StatelessWidget {
//   const ProductListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cat = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Gaseosas';
//     const items = [
//       ('Coca Cola', r'$12.000', '1/2 Plastico'),
//       ('Pessi', r'$10.000', '3 L Plastico'),
//       ('Colombiana', r'$8.000', '1/2 Plastico'),
//     ];
//     return AppScaffold(
//       left: [navHome(context), navProfile(context)],
//       right: [navBell(context), navCart(context)],
//       fab: const AiAvatar(),
//       body: Column(children: [
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//         Expanded(
//           child: ListView(children: [
//             for (final p in items)
//               ProductCard(
//                 name: p.$1,
//                 price: p.$2,
//                 unit: p.$3,
//                 trailing: Column(mainAxisSize: MainAxisSize.min, children: [
//                   const QtyStepper(),
//                   const SizedBox(height: 6),
//                   BlueButton('Agregar al carrito', onTap: () {}),
//                 ]),
//               ),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// /// Carrito de compras
// class CartScreen extends StatelessWidget {
//   const CartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const items = [
//       ('Coca Cola', r'$12.000', r'$12.000'),
//       ('Pessi', r'$10.000', r'$10.000'),
//       ('Colombiana', r'$8.000', r'$8.000'),
//     ];
//     return AppScaffold(
//       left: [navHome(context), navProfile(context)],
//       right: [navBell(context)],
//       body: Column(children: [
//         const Padding(
//           padding: EdgeInsets.all(12),
//           child: Text('Carrito de compras',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//         Expanded(
//           child: ListView(children: [
//             for (final p in items)
//               ProductCard(
//                 name: p.$1,
//                 price: p.$2,
//                 trailing: Column(mainAxisSize: MainAxisSize.min, children: [
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const QtyStepper(),
//                     IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () {}),
//                   ]),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                         color: kAccent, borderRadius: BorderRadius.circular(4)),
//                     child: Text(p.$3, style: const TextStyle(fontSize: 11)),
//                   ),
//                 ]),
//               ),
//           ]),
//         ),
//         Container(
//           color: kBar,
//           padding: const EdgeInsets.all(16),
//           child: Column(children: [
//             const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Text('Total:'),
//               Text(r'$30.000'),
//             ]),
//             const SizedBox(height: 8),
//             BlueButton('Iniciar compra', onTap: () => Navigator.pushNamed(context, '/pedido')),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// /// Pedido / checkout
// class OrderScreen extends StatefulWidget {
//   const OrderScreen({super.key});
//   @override
//   State<OrderScreen> createState() => _OrderScreenState();
// }

// class _OrderScreenState extends State<OrderScreen> {
//   final Map<String, bool> pay = {'Nequi': false, 'Davi plata': false, 'Efectivo': false};

//   Widget _label(String t) => Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)));

//   @override
//   Widget build(BuildContext context) => AppScaffold(
//         left: [navHome(context), navProfile(context)],
//         right: [navBell(context), navCart(context)],
//         body: SingleChildScrollView(
//           child: Column(children: [
//             const Padding(
//               padding: EdgeInsets.all(12),
//               child: Text('Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//             const ProductCard(
//                 name: 'Coca Cola 1/2 Plastico', price: 'Total: \$12.00', color: kBg),
//             const Divider(color: Colors.white54),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 _label('Nombre:'),
//                 const GrayField(''),
//                 _label('Direccion:'),
//                 const GrayField(''),
//                 _label('Telefono:'),
//                 const GrayField('', type: TextInputType.phone),
//                 const SizedBox(height: 8),
//                 const Center(child: Text('Metodo de pago:',
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
//                 const SizedBox(height: 6),
//                 Container(
//                   decoration: BoxDecoration(
//                       color: kAccent.withOpacity(.6),
//                       border: Border.all(color: kAccent),
//                       borderRadius: BorderRadius.circular(4)),
//                   child: Column(children: [
//                     for (final e in pay.entries)
//                       CheckboxListTile(
//                         dense: true,
//                         value: e.value,
//                         title: Text(e.key, style: const TextStyle(fontSize: 12)),
//                         controlAffinity: ListTileControlAffinity.leading,
//                         onChanged: (v) => setState(() {
//                           pay.updateAll((k, _) => false);
//                           pay[e.key] = v ?? false;
//                         }),
//                       ),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(child: BlueButton('Realizar Pago', onTap: () {})),
//                 const SizedBox(height: 24),
//               ]),
//             ),
//           ]),
//         ),
//       );
// }

// /// Chat con asistente de IA "xiomy"
// class AiChatScreen extends StatefulWidget {
//   const AiChatScreen({super.key});
//   @override
//   State<AiChatScreen> createState() => _AiChatScreenState();
// }

// class _AiChatScreenState extends State<AiChatScreen> {
//   final ctrl = TextEditingController();
//   final msgs = <(bool, String)>[
//     (false, 'Hola sara, como estas'),
//     (false, 'Hola, necesito saber qué cuesta la gaseosa colombiana'),
//     (true, 'vale, ya te maestro la información'),
//   ];

//   void _send() {
//     if (ctrl.text.trim().isEmpty) return;
//     setState(() => msgs.add((false, ctrl.text.trim())));
//     ctrl.clear();
//   }

//   @override
//   Widget build(BuildContext context) => AppScaffold(
//         left: [navHome(context), navBell(context)],
//         right: [navCart(context), navProfile(context)],
//         body: Column(children: [
//           const SizedBox(height: 12),
//           const CircleAvatar(
//               radius: 30, backgroundColor: Colors.white,
//               child: Icon(Icons.smart_toy, size: 32, color: kBar)),
//           const Text('xiomy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                   color: kPanel.withOpacity(.3),
//                   border: Border.all(color: kAccent, width: 1.5),
//                   borderRadius: BorderRadius.circular(12)),
//               child: Column(children: [
//                 Expanded(
//                   child: ListView(padding: const EdgeInsets.all(10), children: [
//                     for (final m in msgs)
//                       Align(
//                         alignment: m.$1 ? Alignment.centerLeft : Alignment.centerRight,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                               color: m.$1 ? kAccent.withOpacity(.6) : kBar,
//                               borderRadius: BorderRadius.circular(6)),
//                           child: Text(m.$2, style: const TextStyle(fontSize: 11)),
//                         ),
//                       ),
//                   ]),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Row(children: [
//                     Expanded(child: GrayField('Escribe un mensaje', controller: ctrl)),
//                     IconButton(icon: const Icon(Icons.send), onPressed: _send),
//                   ]),
//                 ),
//               ]),
//             ),
//           ),
//         ]),
//       );
// }

// /// Notificaciones
// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const notes = [
//       'Tu pedido ya sera entregado',
//       'Tu pedido ya fue exitoso!!',
//       'Tu pedido ya fue exitoso!!',
//     ];
//     return AppScaffold(
//       left: [navHome(context)],
//       right: [navCart(context), navProfile(context)],
//       body: Column(children: [
//         const Padding(
//           padding: EdgeInsets.all(16),
//           child: Text('Notificaciones', style: TextStyle(fontSize: 20)),
//         ),
//         Expanded(
//           child: BorderPanel(
//             padding: const EdgeInsets.all(10),
//             child: Column(children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//                 decoration: BoxDecoration(
//                     color: kBg, border: Border.all(color: kAccent),
//                     borderRadius: BorderRadius.circular(6)),
//                 child: const Text('Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(height: 10),
//               for (final n in notes)
//                 Container(
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
//                   child: Row(children: [
//                     const Icon(Icons.local_shipping, color: Colors.orange),
//                     const SizedBox(width: 8),
//                     Expanded(child: Text(n,
//                         style: const TextStyle(color: Colors.black, fontSize: 11))),
//                     const Icon(Icons.delete_outline, size: 16, color: Colors.black54),
//                   ]),
//                 ),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }
// }