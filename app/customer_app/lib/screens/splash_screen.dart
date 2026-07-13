import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/brand_logo.dart';

/// Branded entry animation for Sarko Delivery.
///
/// Act 1 — an orange delivery car drives up a winding S-route, "painting" the
/// road and its dashed centre-line as it goes, arriving at a location pin.
/// Act 2 — the road scene dissolves into the Sarko "S-route" logo, then the
/// "Sarko Delivery" wordmark and tagline rise into place.
///
/// Recreates the idea of the reference clip natively (CustomPainter, no video).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Timeline (fractions of the controller's total duration).
  late final Animation<double> _drive; // road draws + car travels
  late final Animation<double> _pinPop; // destination pin appears
  late final Animation<double> _sceneOut; // road scene dissolves
  late final Animation<double> _logoIn; // logo scales in
  late final Animation<double> _textIn; // wordmark + tagline rise

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _drive = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.62, curve: Curves.easeInOut),
    );
    _pinPop = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.52, 0.70, curve: Curves.easeOutBack),
    );
    _sceneOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.66, 0.82, curve: Curves.easeInOut),
    );
    _logoIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.72, 0.90, curve: Curves.easeOutBack),
    );
    _textIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.86, 1.0, curve: Curves.easeOut),
    );

    _c.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 3600));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();

    // Default to the phone's language until the user changes it in settings.
    locale.initFromDevice();
    if (!auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }
    final user = await auth.loadCurrentUser();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, user == null ? '/register' : '/main');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.1,
            colors: [AppColors.roadDark, AppColors.background],
          ),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Act 1 — the driving route.
                Opacity(
                  opacity: (1 - _sceneOut.value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1 - 0.06 * _sceneOut.value,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _RouteScenePainter(
                        drive: _drive.value,
                        pinPop: _pinPop.value,
                      ),
                    ),
                  ),
                ),

                // Act 2 — the logo + wordmark reveal.
                _Reveal(logoIn: _logoIn.value, textIn: _textIn.value, t: t),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The logo + wordmark + tagline that resolve in once the route completes.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.logoIn,
    required this.textIn,
    required this.t,
  });

  final double logoIn;
  final double textIn;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    if (logoIn <= 0) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: logoIn.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * logoIn.clamp(0.0, 1.0),
            child: const BrandLogo(size: 132),
          ),
        ),
        const SizedBox(height: 22),
        Opacity(
          opacity: textIn.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - textIn.clamp(0.0, 1.0))),
            child: Column(
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sarko',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      TextSpan(
                        text: ' Delivery',
                        style: TextStyle(color: AppColors.brandOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.t('tagline'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the winding delivery route: a road that draws itself in as the car
/// travels its leading tip, a dashed white centre-line, a destination pin, and
/// the orange car with headlights.
class _RouteScenePainter extends CustomPainter {
  _RouteScenePainter({required this.drive, required this.pinPop});

  /// 0..1 — how far the car has travelled / how much road is revealed.
  final double drive;

  /// 0..1 — destination pin pop-in.
  final double pinPop;

  Path _buildRoute(Size size) {
    final w = size.width;
    final h = size.height;
    // A vertical S traced bottom -> top, sized to the screen with margins.
    return Path()
      ..moveTo(w * 0.30, h * 0.90)
      ..cubicTo(w * 0.30, h * 0.82, w * 0.80, h * 0.84, w * 0.78, h * 0.72)
      ..cubicTo(w * 0.76, h * 0.60, w * 0.20, h * 0.62, w * 0.22, h * 0.50)
      ..cubicTo(w * 0.24, h * 0.38, w * 0.80, h * 0.40, w * 0.72, h * 0.24);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoute(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final total = metric.length;
    final roadW = size.width * 0.12;
    final drawn = (drive * total).clamp(0.0, total);

    // Road bed (revealed portion only).
    final revealed = metric.extractPath(0, drawn);
    canvas.drawPath(
      revealed,
      Paint()
        ..color = AppColors.roadDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadW
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Subtle highlight so the tarmac reads against the dark backdrop.
    canvas.drawPath(
      revealed,
      Paint()
        ..color = Colors.white.withOpacity(0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadW
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dashed centre-line, drawn only over the revealed length.
    _drawDashes(canvas, metric, drawn, roadW);

    // Destination pin at the very end of the route.
    if (pinPop > 0) {
      final endTangent = metric.getTangentForOffset(total);
      if (endTangent != null) {
        _drawPin(canvas, endTangent.position, roadW * 0.9, pinPop);
      }
    }

    // The car at the leading tip of the revealed road.
    final tan = metric.getTangentForOffset(drawn);
    if (tan != null && drive > 0.001 && drive < 0.999) {
      _drawCar(canvas, tan.position, tan.angle, roadW);
    }
  }

  void _drawDashes(Canvas canvas, PathMetric metric, double end, double roadW) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadW * 0.07
      ..strokeCap = StrokeCap.round;
    const dash = 20.0;
    const gap = 16.0;
    double dist = 0;
    bool on = true;
    while (dist < end) {
      final seg = on ? dash : gap;
      final next = math.min(dist + seg, end);
      if (on) canvas.drawPath(metric.extractPath(dist, next), paint);
      dist = next;
      on = !on;
    }
  }

  void _drawPin(Canvas canvas, Offset c, double r, double pop) {
    final s = pop.clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(s);
    canvas.translate(0, -r * 0.6); // sit the tip near the road end
    final white = Paint()..color = Colors.white;
    final head = Offset(0, -r * 0.2);
    // Teardrop: circle head + triangle to the tip.
    final body = Path()
      ..moveTo(-r * 0.62, head.dy + r * 0.28)
      ..lineTo(r * 0.62, head.dy + r * 0.28)
      ..lineTo(0, r * 0.9)
      ..close();
    canvas.drawPath(body, white);
    canvas.drawCircle(head, r * 0.62, white);
    canvas.drawCircle(head, r * 0.28, Paint()..color = AppColors.brandOrange);
    canvas.restore();
  }

  void _drawCar(Canvas canvas, Offset pos, double angle, double roadW) {
    final len = roadW * 0.92;
    final wid = roadW * 0.56;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle); // +x points in the travel direction

    // Headlight glow ahead of the car.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.brandOrangeLight.withOpacity(0.55),
          AppColors.brandOrangeLight.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(len * 0.95, 0), radius: len * 0.9),
      );
    canvas.drawCircle(Offset(len * 0.9, 0), len * 0.85, glow);

    // Body (rounded), nose pointing +x.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: len, height: wid),
        Radius.circular(wid * 0.42),
      ),
      Paint()
        ..color = AppColors.brandOrange
        ..style = PaintingStyle.fill,
    );
    // Windshield hint.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(len * 0.1, 0),
          width: len * 0.32,
          height: wid * 0.66,
        ),
        Radius.circular(wid * 0.2),
      ),
      Paint()..color = AppColors.roadDarker.withOpacity(0.85),
    );
    // Twin headlights.
    final hl = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(len * 0.45, -wid * 0.28), wid * 0.09, hl);
    canvas.drawCircle(Offset(len * 0.45, wid * 0.28), wid * 0.09, hl);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RouteScenePainter old) =>
      old.drive != drive || old.pinPop != pinPop;
}
