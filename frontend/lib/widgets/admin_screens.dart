import 'package:flutter/material.dart';
import 'core.dart';

/// Fila de inventario/stock con cantidad en verde o rojo.
class _StockRow extends StatelessWidget {
  final String name, price, unit, qty;
  final Color qtyColor;
  const _StockRow(this.name, this.price, this.unit, this.qty, this.qtyColor);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
        child: Row(children: [
          const Icon(Icons.local_drink, color: Colors.black87, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.black, fontSize: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price),
                Text(unit),
              ]),
            ),
          ),
          Column(children: [
            Text(qty,
                style: TextStyle(color: qtyColor, fontSize: 11, fontWeight: FontWeight.bold)),
            const Text('UD', style: TextStyle(color: Colors.black, fontSize: 10)),
          ]),
        ]),
      );
}

/// Inventario
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        left: [navHome(context)],
        right: [navStock(context), navProfile(context)],
        center: SizedBox(
          height: 30,
          child: TextField(
            style: const TextStyle(color: Colors.black, fontSize: 11),
            decoration: InputDecoration(
              hintText: 'Buscar Producto',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, size: 16, color: Colors.black54),
              contentPadding: EdgeInsets.zero,
              isDense: true, filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        body: Column(children: [
          Expanded(
            child: BorderPanel(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                  decoration: BoxDecoration(
                      color: kBg, border: Border.all(color: kAccent),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('inventario'),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(children: const [
                    _StockRow('Colombiana 1/2', r'$8.000', 'Plastico', '30', Colors.green),
                    _StockRow('Jugo Hit', r'$6.000', 'Caja', '25', Colors.green),
                    _StockRow('Coca Cola 1/2', r'$12.000', 'Plastico', '40', Colors.green),
                    _StockRow('Paca de Aguila', r'$24.000', 'Lata', '12', Colors.green),
                    _StockRow('Pessi 3L', r'$10.000', 'Plastico', '20', Colors.green),
                    _StockRow('Monster', r'$10.000', 'Lata', '9', Colors.red),
                  ]),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const AiAvatar(),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/ingresar'),
                    child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.add, size: 20, color: Colors.white)),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      );
}

/// Ingresar productos
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  Widget _label(String t) => Align(
      alignment: Alignment.centerLeft,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(t, style: const TextStyle(fontSize: 11))));

  Widget _blue() => Container(
      height: 24,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFBBDEFB), borderRadius: BorderRadius.circular(4)));

  @override
  Widget build(BuildContext context) => AppScaffold(
        left: [navHome(context)],
        right: [navStock(context), navProfile(context)],
        body: SingleChildScrollView(
          child: BorderPanel(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.photo_camera, size: 36, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  const Text('Anexar imagen',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 16),
              _label('Nombre del Producto'),
              const TextField(style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(isDense: true, filled: true,
                      fillColor: Color(0xFFBBDEFB), border: InputBorder.none)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Column(children: [_label('Valor'), _blue()])),
                const SizedBox(width: 16),
                Expanded(child: Column(children: [_label('Cantidad'), _blue()])),
              ]),
              _label('Categoria'),
              _blue(),
              _label('Descripcion del producto'),
              _blue(),
              const SizedBox(height: 12),
              Center(child: BlueButton('Agregar')),
            ]),
          ),
        ),
      );
}

/// Stock
class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        left: [navHome(context)],
        right: [navProfile(context)],
        body: Column(children: [
          Expanded(
            child: BorderPanel(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Stock',
                        style: TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.inventory_2, color: Colors.orange, size: 18),
                  ]),
                ),
                const SizedBox(height: 10),
                const _StockRow('Monster', r'$10.000', 'Lata', '9', Colors.red),
                const _StockRow('Agua Cristal', r'$7.000', 'Plastico', '8', Colors.red),
              ]),
            ),
          ),
        ]),
      );
}