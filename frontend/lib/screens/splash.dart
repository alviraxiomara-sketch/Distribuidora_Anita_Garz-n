import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Duración total de la pantalla de bienvenida
  static const Duration _duracionTotal = Duration(milliseconds: 5000);

  // Entrada escalonada del logo y los textos
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Burbujas flotando de fondo (bucle continuo)
  late final AnimationController _burbujas = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  // Brillo que "respira" alrededor del logo
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  // Barra de progreso y tiempo total
  late final AnimationController _progreso = AnimationController(
    vsync: this,
    duration: _duracionTotal,
  );

  late final Animation<double> _logoOpacidad = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
  );

  late final Animation<double> _logoEscala = Tween<double>(begin: 0.6, end: 1.0)
      .animate(
        CurvedAnimation(
          parent: _entrada,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
        ),
      );

  late final Animation<double> _bienvenidaOpacidad = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> _tituloOpacidad = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
  );

  late final Animation<Offset> _tituloDesplazamiento =
      Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entrada,
          curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
        ),
      );

  late final Animation<double> _sloganOpacidad = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
  );

  late final List<_Burbuja> _listaBurbujas = _generarBurbujas();

  @override
  void initState() {
    super.initState();
    debugPrint('SPLASH NUEVO MOSTRADO');
    _entrada.forward();
    _burbujas.repeat();
    _pulso.repeat(reverse: true);
    _progreso.forward().whenComplete(_irAlInicio);
  }

  List<_Burbuja> _generarBurbujas() {
    final random = math.Random(7);
    return List.generate(18, (_) {
      return _Burbuja(
        x: random.nextDouble(),
        tamano: 6 + random.nextDouble() * 22,
        vueltas: random.nextBool() ? 1 : 2,
        fase: random.nextDouble(),
        opacidad: 0.25 + random.nextDouble() * 0.5,
        oscilacion: 6 + random.nextDouble() * 14,
      );
    });
  }

  void _irAlInicio() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entrada.dispose();
    _burbujas.dispose();
    _pulso.dispose();
    _progreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF063B5D), Color(0xFF031A2E), Color(0xFF020F1A)],
          ),
        ),
        child: Stack(
          children: [
            // Burbujas de fondo
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _burbujas,
                builder: (_, __) => CustomPaint(
                  painter: _BurbujasPainter(_burbujas.value, _listaBurbujas),
                ),
              ),
            ),

            // Positioned.fill hace que el contenido ocupe todo el ancho
            // y quede realmente centrado en la pantalla
            Positioned.fill(
              child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo con brillo
                    FadeTransition(
                      opacity: _logoOpacidad,
                      child: ScaleTransition(
                        scale: _logoEscala,
                        child: _buildLogo(),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Texto de bienvenida
                    FadeTransition(
                      opacity: _bienvenidaOpacidad,
                      child: const Text(
                        '¡BIENVENIDO A!',
                        style: TextStyle(
                          color: Color(0xFF00A8FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nombre del negocio
                    FadeTransition(
                      opacity: _tituloOpacidad,
                      child: SlideTransition(
                        position: _tituloDesplazamiento,
                        child: const Text(
                          'Distribuidora\nAnita',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Eslogan
                    FadeTransition(
                      opacity: _sloganOpacidad,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A8FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Los mejores productos al mejor precio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Barra de progreso
                    FadeTransition(
                      opacity: _sloganOpacidad,
                      child: _buildProgreso(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulso,
      builder: (_, child) {
        final brillo = Curves.easeInOut.transform(_pulso.value);
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00A8FF).withOpacity(0.25 + brillo * 0.3),
                blurRadius: 24 + brillo * 26,
                spreadRadius: 2 + brillo * 6,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: 170,
        height: 170,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF063B5D),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.local_drink, color: Colors.white, size: 70),
          ),
        ),
      ),
    );
  }

  Widget _buildProgreso() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progreso,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: Curves.easeInOut.transform(_progreso.value),
                minHeight: 5,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00A8FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cargando...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Datos de cada burbuja de fondo
class _Burbuja {
  final double x;
  final double tamano;
  final int vueltas;
  final double fase;
  final double opacidad;
  final double oscilacion;

  const _Burbuja({
    required this.x,
    required this.tamano,
    required this.vueltas,
    required this.fase,
    required this.opacidad,
    required this.oscilacion,
  });
}

// Dibuja las burbujas subiendo suavemente
class _BurbujasPainter extends CustomPainter {
  final double progreso;
  final List<_Burbuja> burbujas;

  _BurbujasPainter(this.progreso, this.burbujas);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in burbujas) {
      // 0 = abajo, 1 = arriba
      final avance = (progreso * b.vueltas + b.fase) % 1.0;
      final y = size.height * (1 - avance);
      final x =
          size.width * b.x +
          math.sin(avance * 2 * math.pi * 2 + b.fase * 6) * b.oscilacion;

      // Aparece y se desvanece suavemente en los extremos
      final visibilidad = math.sin(avance * math.pi) * b.opacidad;
      final centro = Offset(x, y);
      final radio = b.tamano / 2;

      final relleno = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF00A8FF).withOpacity(0.10 * visibilidad);
      final borde = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.35 * visibilidad);
      final reflejo = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(0.5 * visibilidad);

      canvas.drawCircle(centro, radio, relleno);
      canvas.drawCircle(centro, radio, borde);
      canvas.drawCircle(
        centro.translate(-radio * 0.35, -radio * 0.35),
        radio * 0.18,
        reflejo,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurbujasPainter oldDelegate) =>
      oldDelegate.progreso != progreso;
}