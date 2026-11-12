import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/widgets/admin_drawer.dart';
import 'package:frontend/screens/principal_admin.dart';
import 'package:frontend/screens/profile.dart';

class VentasAdmin extends StatefulWidget {
  const VentasAdmin({super.key});

  @override
  State<VentasAdmin> createState() => _VentasAdminState();
}

class _VentasAdminState extends State<VentasAdmin> {
  static const _fondo = Color(0xFF031A2E);
  static const _tarjeta = Color(0xFF063B5D);
  static const _azul = Color(0xFF00A8FF);

  final ScrollController _scrollDiario = ScrollController();

  bool _cargando = true;
  String? _error;

  double _totalHoy = 0, _totalMes = 0, _totalPeriodo = 0;
  int _pedidosHoy = 0, _pedidosMes = 0, _pedidosPeriodo = 0;
  List<Map<String, dynamic>> _diarias = [];
  List<Map<String, dynamic>> _mensuales = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  @override
  void dispose() {
    _scrollDiario.dispose();
    super.dispose();
  }

  Future<void> _cargarVentas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ventas/resumen'),
        headers: {
          ...ApiConfig.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() {
          _error = 'Error ${res.statusCode} al cargar las ventas';
          _cargando = false;
        });
        return;
      }

      final d = jsonDecode(res.body);

      setState(() {
        _totalHoy = (d['total_hoy'] ?? 0).toDouble();
        _totalMes = (d['total_mes'] ?? 0).toDouble();
        _totalPeriodo = (d['total_periodo'] ?? 0).toDouble();
        _pedidosHoy = (d['pedidos_hoy'] ?? 0).toInt();
        _pedidosMes = (d['pedidos_mes'] ?? 0).toInt();
        _pedidosPeriodo = (d['pedidos_periodo'] ?? 0).toInt();
        _diarias = List<Map<String, dynamic>>.from(d['diarias'] ?? []);
        _mensuales = List<Map<String, dynamic>>.from(d['mensuales'] ?? []);
        _cargando = false;
      });

      // Deja el gráfico diario mostrando los días más recientes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollDiario.hasClients) {
          _scrollDiario.jumpTo(_scrollDiario.position.maxScrollExtent);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con el servidor';
        _cargando = false;
      });
    }
  }

  // ---------- Formateadores ----------
  String _moneda(num v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '\$${b.toString()}';
  }

  String _compacto(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _nombreMes(String clave) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final m = int.tryParse(clave.split('-').last) ?? 1;
    return meses[m - 1];
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: _tarjeta,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ventas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // El botón de menú lateral aparece solo porque hay un drawer
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Inicio',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalAdminScreen()),
              (route) => false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: _azul))
          : _error != null
              ? _vistaError()
              : RefreshIndicator(
                  color: _azul,
                  onRefresh: _cargarVentas,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _resumenTarjetas(),
                      const SizedBox(height: 20),
                      _tituloSeccion('Ventas mensuales (últimos 12 meses)'),
                      _contenedorGrafico(_graficoMensual()),
                      const SizedBox(height: 20),
                      _tituloSeccion('Ventas diarias (últimos 30 días)'),
                      _contenedorGrafico(_graficoDiario()),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Solo se cuentan pedidos que no estén pendientes, cancelados ni rechazados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFB0BEC5), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _vistaError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _azul, foregroundColor: Colors.white),
              onPressed: _cargarVentas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSeccion(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        texto,
        style: const TextStyle(
          color: _azul,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _contenedorGrafico(Widget hijo) {
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(8, 20, 12, 8),
      decoration: BoxDecoration(
        color: _tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _azul.withOpacity(0.5), width: 1.2),
      ),
      child: hijo,
    );
  }

  // ---------- Tarjetas de resumen ----------
  Widget _resumenTarjetas() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _tarjetaResumen(
                icono: Icons.today_rounded,
                titulo: 'Hoy',
                valor: _moneda(_totalHoy),
                detalle: '$_pedidosHoy pedidos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tarjetaResumen(
                icono: Icons.calendar_month_rounded,
                titulo: 'Este mes',
                valor: _moneda(_totalMes),
                detalle: '$_pedidosMes pedidos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _tarjetaResumen(
          icono: Icons.insights_rounded,
          titulo: 'Total últimos 12 meses',
          valor: _moneda(_totalPeriodo),
          detalle: '$_pedidosPeriodo pedidos',
        ),
      ],
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required String detalle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _tarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _azul.withOpacity(0.6), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _fondo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: _azul, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        color: Color(0xFFB0BEC5), fontSize: 11)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(valor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ),
                Text(detalle,
                    style: const TextStyle(color: _azul, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Gráficos ----------
  double _maxY(List<Map<String, dynamic>> datos) {
    double m = 0;
    for (final d in datos) {
      final t = (d['total'] ?? 0).toDouble();
      if (t > m) m = t;
    }
    return m <= 0 ? 100000 : m * 1.2;
  }

  FlTitlesData _titulos(double maxY, Widget Function(double, TitleMeta) bottom,
      double anchoIzq) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: anchoIzq,
          interval: maxY / 4,
          getTitlesWidget: (v, meta) {
            if (v == meta.max) return const SizedBox.shrink();
            return Text(_compacto(v),
                style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 10));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          getTitlesWidget: bottom,
        ),
      ),
    );
  }

  FlGridData _grilla(double maxY) => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.white12, strokeWidth: 1),
      );

  Widget _graficoMensual() {
    final maxY = _maxY(_mensuales);

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: _grilla(maxY),
        borderData: FlBorderData(show: false),
        titlesData: _titulos(maxY, (v, meta) {
          final i = v.toInt();
          if (i < 0 || i >= _mensuales.length) return const SizedBox.shrink();
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(_nombreMes(_mensuales[i]['mes']),
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          );
        }, 36),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => _fondo,
            getTooltipItem: (group, gi, rod, ri) {
              final m = _mensuales[group.x];
              return BarTooltipItem(
                '${_nombreMes(m['mes'])} ${m['mes'].toString().substring(0, 4)}\n'
                '${_moneda(rod.toY)}\n${m['pedidos']} pedidos',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        barGroups: List.generate(_mensuales.length, (i) {
          final esActual = i == _mensuales.length - 1;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: (_mensuales[i]['total'] ?? 0).toDouble(),
              width: 14,
              color: esActual ? _azul : _azul.withOpacity(0.55),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _graficoDiario() {
    final maxY = _maxY(_diarias);
    // Ancho fijo por barra para poder desplazar horizontalmente
    final ancho = (_diarias.length * 26.0) + 40;

    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        controller: _scrollDiario,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: ancho < c.maxWidth ? c.maxWidth : ancho,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: _grilla(maxY),
              borderData: FlBorderData(show: false),
              titlesData: _titulos(maxY, (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= _diarias.length) {
                  return const SizedBox.shrink();
                }
                final dia = _diarias[i]['fecha'].toString().substring(8, 10);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(dia,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 9)),
                );
              }, 36),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => _fondo,
                  getTooltipItem: (group, gi, rod, ri) {
                    final d = _diarias[group.x];
                    return BarTooltipItem(
                      '${d['fecha']}\n${_moneda(rod.toY)}\n${d['pedidos']} pedidos',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              barGroups: List.generate(_diarias.length, (i) {
                final esHoy = i == _diarias.length - 1;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: (_diarias[i]['total'] ?? 0).toDouble(),
                    width: 12,
                    color: esHoy ? Colors.greenAccent : _azul.withOpacity(0.7),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ]);
              }),
            ),
          ),
        ),
      );
    });
  }
}