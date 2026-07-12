import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kQiblahCacheKey = 'qiblah_v2_bearing';

// Shortest-path angle interpolation (handles 359° → 1° correctly).
double _lerpAngle(double from, double to, double t) {
  double diff = (to - from) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return from + diff * t;
}

// ─── Entry point ─────────────────────────────────────────────────────────────

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

enum _PermState { checking, ok, locationOff, denied, deniedForever, noSensor }

class _QiblahScreenState extends State<QiblahScreen> {
  _PermState _perm = _PermState.checking;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => _perm = _PermState.checking);

    // Android-only check — iOS always has a magnetometer.
    if (Platform.isAndroid) {
      final ok = await FlutterQiblah.androidDeviceSensorSupport() ?? false;
      if (!ok) {
        if (mounted) setState(() => _perm = _PermState.noSensor);
        return;
      }
    }

    final loc = await FlutterQiblah.checkLocationStatus();
    if (!mounted) return;

    if (!loc.enabled) {
      setState(() => _perm = _PermState.locationOff);
      return;
    }
    if (loc.status == LocationPermission.deniedForever) {
      setState(() => _perm = _PermState.deniedForever);
      return;
    }
    if (loc.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      if (!mounted) return;
      final updated = await FlutterQiblah.checkLocationStatus();
      if (!mounted) return;
      if (updated.status == LocationPermission.deniedForever) {
        setState(() => _perm = _PermState.deniedForever);
        return;
      }
      if (updated.status == LocationPermission.denied) {
        setState(() => _perm = _PermState.denied);
        return;
      }
    }

    setState(() => _perm = _PermState.ok);
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xff091a09), const Color(0xff1c1c1c)]
                : [const Color(0xffe8f5e9), const Color(0xfffafafa)],
          ),
        ),
        child: SafeArea(child: _body(isDark)),
      ),
    );
  }

  Widget _body(bool isDark) {
    switch (_perm) {
      case _PermState.checking:
        return const Center(child: CircularProgressIndicator.adaptive());
      case _PermState.ok:
        return _QiblahCompass(isDark: isDark);
      case _PermState.locationOff:
        return _ErrorView(
          icon: Icons.location_off,
          title: 'Standortdienst deaktiviert',
          message: 'Bitte aktiviere den Standortdienst auf deinem Gerät.',
          onAction: _init,
        );
      case _PermState.denied:
        return _ErrorView(
          icon: Icons.location_off,
          title: 'Standortberechtigung abgelehnt',
          message:
              'Bitte erlaube der App den Zugriff auf deinen Standort, um die Qibla-Richtung zu berechnen.',
          onAction: _init,
        );
      case _PermState.deniedForever:
        return _ErrorView(
          icon: Icons.location_disabled,
          title: 'Berechtigung dauerhaft verweigert',
          message:
              'Öffne die App-Einstellungen und erlaube den Standortzugriff.',
          actionLabel: 'Einstellungen öffnen',
          onAction: () async {
            await Geolocator.openAppSettings();
            await _init();
          },
        );
      case _PermState.noSensor:
        return _ErrorView(
          icon: Icons.explore_off,
          title: 'Kein Kompasssensor',
          message: 'Dein Gerät unterstützt keinen Magnetometer-Sensor.',
          onAction: _init,
        );
    }
  }
}

// ─── Compass ─────────────────────────────────────────────────────────────────

class _QiblahCompass extends StatefulWidget {
  const _QiblahCompass({required this.isDark});
  final bool isDark;

  @override
  State<_QiblahCompass> createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<_QiblahCompass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  StreamSubscription<QiblahDirection>? _sub;

  // Raw targets received from the sensor stream
  double _targetDir = 0;
  double _targetQiblah = 0;
  double _liveOffset = 0;

  // Smoothly interpolated display values (updated on every tick)
  double _dir = 0;
  double _qiblah = 0;

  bool _hasLiveData = false;
  double? _lastSaved;

  @override
  void initState() {
    super.initState();
    _loadCachedQiblah(); // show last-known bearing before first GPS fix

    // AnimationController used as a 60-fps ticker only — duration is irrelevant.
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..repeat()
      ..addListener(_tick);

    _sub = FlutterQiblah.qiblahStream.listen(_onData);
  }

  void _tick() {
    setState(() {
      _dir = _lerpAngle(_dir, _targetDir, 0.14);
      _qiblah = _lerpAngle(_qiblah, _targetQiblah, 0.14);
    });
  }

  void _onData(QiblahDirection data) {
    if (!_hasLiveData) {
      // Snap to first reading so there is no long animation from 0.
      _dir = data.direction;
      _qiblah = data.qiblah;
      _hasLiveData = true;
    }
    _targetDir = data.direction;
    _targetQiblah = data.qiblah;
    _liveOffset = data.offset;
    _maybeSave(data.qiblah);
  }

  Future<void> _loadCachedQiblah() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getDouble(_kQiblahCacheKey);
    if (cached != null && !_hasLiveData && mounted) {
      setState(() {
        _targetQiblah = cached;
        _qiblah = cached;
      });
    }
  }

  // Only write to disk when the bearing shifts by more than 1° (avoids
  // constant IO from minor sensor noise while holding the phone still).
  void _maybeSave(double qiblah) async {
    if (_lastSaved != null && (qiblah - _lastSaved!).abs() < 1) return;
    _lastSaved = qiblah;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kQiblahCacheKey, qiblah);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aligned = _hasLiveData && _liveOffset.abs() < 5;
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xff1b5e20);

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        const SizedBox(height: 22),
        Text(
          'Qibla Kompass',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Richtung zur Kaaba in Mekka',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 20),

        // ── Compass ──────────────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final size = constraints.maxWidth.clamp(0.0, 360.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: CustomPaint(
                      painter: _QiblahPainter(
                        direction: _dir,
                        qiblah: _qiblah,
                        isDark: isDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Status area ──────────────────────────────────────────────────────
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: !_hasLiveData
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kompass wird kalibriert…',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('live'),
                  children: [
                    Icon(
                      aligned ? Icons.check_circle_rounded : Icons.explore,
                      color: aligned ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      aligned ? 'Du zeigst zur Qibla ✓' : 'Richtung zur Qibla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: aligned
                            ? Colors.green
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_liveOffset.abs().toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _QiblahPainter extends CustomPainter {
  const _QiblahPainter({
    required this.direction,
    required this.qiblah,
    required this.isDark,
  });

  final double direction;
  final double qiblah;
  final bool isDark;

  static const double _deg = pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint();

    // ── Background circle ─────────────────────────────────────────────────
    paint.color = isDark ? const Color(0xff0f230f) : const Color(0xfff0faf0);
    canvas.drawCircle(center, r, paint);

    // Subtle inner ring
    paint
      ..color = (isDark ? Colors.green.shade900 : Colors.green.shade100)
          .withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    canvas.drawCircle(center, r * 0.88, paint);
    paint.style = PaintingStyle.fill;

    // ── Compass face — rotates with the device ────────────────────────────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-direction * _deg);
    _drawFace(canvas, r);
    canvas.restore();

    // ── Qibla arrow — stays pointing at Mecca regardless of rotation ──────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-qiblah * _deg);
    _drawArrow(canvas, r);
    canvas.restore();

    // ── Center knob ───────────────────────────────────────────────────────
    paint.color = isDark ? const Color(0xff1a3a1a) : Colors.white;
    canvas.drawCircle(center, r * 0.07, paint);
    paint.color = Colors.green.shade600;
    canvas.drawCircle(center, r * 0.045, paint);

    // ── Outer border ──────────────────────────────────────────────────────
    paint
      ..color = isDark ? Colors.green.shade800 : Colors.green.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r - 1, paint);
  }

  // Draws compass rose (tick marks + cardinal labels) in compass-local space.
  // The canvas is already translated to center and rotated by -direction.
  void _drawFace(Canvas canvas, double r) {
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * _deg;
      final isCardinal = i % 18 == 0; // 0°, 90°, 180°, 270°
      final isMajor = i % 9 == 0; // intercardinal 45°, 135°, etc.

      final outerR = r * 0.95;
      final tickLen = isCardinal
          ? r * 0.14
          : isMajor
              ? r * 0.09
              : r * 0.05;

      tick
        ..color = isCardinal
            ? (i == 0
                ? Colors.red.shade400
                : (isDark ? Colors.white : Colors.black87))
            : (isDark
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.2))
        ..strokeWidth = isCardinal
            ? 2.8
            : isMajor
                ? 1.5
                : 1.0;

      final s = sin(angle);
      final c = cos(angle);
      canvas.drawLine(
        Offset(outerR * s, -outerR * c),
        Offset((outerR - tickLen) * s, -(outerR - tickLen) * c),
        tick,
      );
    }

    // Cardinal labels — counter-rotated so text stays upright on screen.
    _drawLabel(canvas, 'N', 0, r, Colors.red.shade400, 20, FontWeight.bold);
    _drawLabel(canvas, 'O', pi / 2, r,
        isDark ? Colors.white70 : Colors.black54, 15, FontWeight.w600);
    _drawLabel(canvas, 'S', pi, r,
        isDark ? Colors.white70 : Colors.black54, 15, FontWeight.w600);
    _drawLabel(canvas, 'W', 3 * pi / 2, r,
        isDark ? Colors.white70 : Colors.black54, 15, FontWeight.w600);
  }

  void _drawLabel(Canvas canvas, String text, double angle, double r,
      Color color, double fontSize, FontWeight weight) {
    final labelR = r * 0.73;
    final x = labelR * sin(angle);
    final y = -labelR * cos(angle);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(x, y);
    // Cancel the outer -direction rotation so the label reads upright.
    canvas.rotate(direction * _deg);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  // Draws the Qibla arrow in compass-local space already rotated to -qiblah.
  // The tip of the arrow points toward the top of this local space = Mecca.
  void _drawArrow(Canvas canvas, double r) {
    final len = r * 0.74;
    final w = r * 0.08;
    final paint = Paint();

    // Drop shadow
    final shadowPath = Path()
      ..moveTo(0, -len)
      ..lineTo(-w, -len * 0.28)
      ..lineTo(-w * 0.45, 0)
      ..lineTo(w * 0.45, 0)
      ..lineTo(w, -len * 0.28)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Arrow body (dark green base)
    final arrowPath = Path()
      ..moveTo(0, -len)
      ..lineTo(-w, -len * 0.28)
      ..lineTo(-w * 0.45, 0)
      ..lineTo(w * 0.45, 0)
      ..lineTo(w, -len * 0.28)
      ..close();

    paint
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);

    // Bright highlight on upper half
    final highlightPath = Path()
      ..moveTo(0, -len)
      ..lineTo(-w, -len * 0.28)
      ..lineTo(0, -len * 0.28)
      ..close();
    paint.color = Colors.green.shade400;
    canvas.drawPath(highlightPath, paint);

    // Arrow outline
    paint
      ..color = Colors.green.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(arrowPath, paint);
    paint.style = PaintingStyle.fill;

    // ── Kaaba icon at the tip ─────────────────────────────────────────────
    final kSize = r * 0.095;
    final kTop = -len - kSize * 0.5;

    // Black cube body
    paint.color = const Color(0xff1a1a1a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, kTop),
          width: kSize,
          height: kSize,
        ),
        Radius.circular(kSize * 0.15),
      ),
      paint,
    );

    // Golden door (Bab al-Tawbah)
    paint.color = const Color(0xffD4A017);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, kTop + kSize * 0.15),
        width: kSize * 0.3,
        height: kSize * 0.45,
      ),
      paint,
    );

    // White Kiswa stripe
    paint
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = kSize * 0.1;
    canvas.drawLine(
      Offset(-kSize * 0.45, kTop - kSize * 0.05),
      Offset(kSize * 0.45, kTop - kSize * 0.05),
      paint,
    );
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(_QiblahPainter old) =>
      direction != old.direction ||
      qiblah != old.qiblah ||
      isDark != old.isDark;
}

// ─── Error / permission view ──────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onAction,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionLabel != null ? Icons.settings : Icons.refresh),
              label: Text(actionLabel ?? 'Erneut versuchen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
