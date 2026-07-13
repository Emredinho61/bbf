// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kQiblahCacheKey = 'qiblah_v2_bearing';

double _lerpAngle(double from, double to, double t) {
  double diff = (to - from) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return from + diff * t;
}

// ─── Entry point ──────────────────────────────────────────────────────────────

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
      backgroundColor:
          isDark ? BColors.backgroundColorDark : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: BColors.primary, size: 18.sp),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Qibla Kompass',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded,
                color: BColors.primary, size: 22.sp),
            onPressed: () => _showCalibrationTip(context),
          ),
        ],
      ),
      body: _body(isDark),
    );
  }

  void _showCalibrationTip(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Kalibrierung'),
        content: const Text(
          'Bewege dein Gerät in einer liegenden 8-Form, um den Kompass zu '
          'kalibrieren. Halte das Gerät dabei flach.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: BColors.primary)),
          ),
        ],
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
          icon: Icons.location_off_rounded,
          title: 'Standortdienst deaktiviert',
          message: 'Bitte aktiviere den Standortdienst auf deinem Gerät.',
          onAction: _init,
        );
      case _PermState.denied:
        return _ErrorView(
          icon: Icons.location_off_rounded,
          title: 'Standortberechtigung abgelehnt',
          message:
              'Bitte erlaube der App den Zugriff auf deinen Standort, um die Qibla-Richtung zu berechnen.',
          onAction: _init,
        );
      case _PermState.deniedForever:
        return _ErrorView(
          icon: Icons.location_disabled_rounded,
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
          icon: Icons.explore_off_rounded,
          title: 'Kein Kompasssensor',
          message: 'Dein Gerät unterstützt keinen Magnetometer-Sensor.',
          onAction: _init,
        );
    }
  }
}

// ─── Compass widget ───────────────────────────────────────────────────────────

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

  // Smoothed display values
  double _dir = 0;
  double _offset = 0;
  double _qiblah = 0;

  // Raw targets
  double _targetDir = 0;
  double _targetOffset = 0;
  double _targetQiblah = 0;

  bool _hasLiveData = false;
  double? _lastSaved;
  DateTime? _lastUpdate;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _loadCachedQiblah();
    _loadPosition();

    // Ticker drives AnimatedBuilder for compass only — no full-widget setState
    _ticker =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..repeat();

    _sub = FlutterQiblah.qiblahStream.listen(_onData);
  }

  void _onData(QiblahDirection data) {
    if (!_hasLiveData) {
      // Snap lerped values to first reading so compass doesn't sweep from 0°
      _dir = data.direction;
      _offset = data.offset;
      _qiblah = data.qiblah;
      _hasLiveData = true;
    }
    setState(() {
      _targetDir = data.direction;
      _targetOffset = data.offset;
      _targetQiblah = data.qiblah;
      _lastUpdate = DateTime.now();
    });
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

  Future<void> _loadPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _position = pos);
    } catch (_) {}
  }

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

  double? get _distanceKm {
    if (_position == null) return null;
    return Geolocator.distanceBetween(
            _position!.latitude, _position!.longitude, 21.4225, 39.8262) /
        1000;
  }

  String _accuracyLabel() {
    if (_position == null || !_hasLiveData) return '–';
    final acc = _position!.accuracy;
    if (acc <= 15) return 'Sehr hoch';
    if (acc <= 50) return 'Hoch';
    if (acc <= 150) return 'Mittel';
    return 'Niedrig';
  }

  String _lastUpdateLabel() {
    if (_lastUpdate == null) return 'Ausstehend';
    final diff = DateTime.now().difference(_lastUpdate!);
    if (diff.inSeconds < 5) return 'Gerade eben';
    if (diff.inSeconds < 60) return 'Vor ${diff.inSeconds}s';
    return 'Vor ${diff.inMinutes} min';
  }

  String _directionLabel() {
    final d = ((_qiblah % 360) + 360) % 360;
    if (d < 22.5) return 'Nördlich';
    if (d < 67.5) return 'Nordöstlich';
    if (d < 112.5) return 'Östlich';
    if (d < 157.5) return 'Südöstlich';
    if (d < 202.5) return 'Südlich';
    if (d < 247.5) return 'Südwestlich';
    if (d < 292.5) return 'Westlich';
    if (d < 337.5) return 'Nordwestlich';
    return 'Nördlich';
  }

  String _formatDistance(double km) {
    final i = km.round();
    if (i >= 1000) {
      return '${i ~/ 1000}.${(i % 1000).toString().padLeft(3, '0')} km';
    }
    return '$i km';
  }

  String? _guessCountry() {
    final pos = _position;
    if (pos == null) return null;
    if (pos.latitude >= 47 &&
        pos.latitude <= 55 &&
        pos.longitude >= 6 &&
        pos.longitude <= 15) {
      return 'Deutschland';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final green = BColors.primary;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // ── Location card ────────────────────────────────────────────────
          _locationCard(isDark, green),
          SizedBox(height: 18.h),

          // ── Compass ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(builder: (_, c) {
                final size = c.maxWidth;
                // AnimatedBuilder rebuilds only this subtree at 60fps,
                // leaving the SingleChildScrollView scroll-position untouched.
                return AnimatedBuilder(
                  animation: _ticker,
                  builder: (_, __) {
                    _dir = _lerpAngle(_dir, _targetDir, 0.14);
                    _qiblah = _lerpAngle(_qiblah, _targetQiblah, 0.14);
                    _offset = _lerpAngle(_offset, _targetOffset, 0.14);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(size, size),
                          painter: _QiblahPainter(
                            direction: _dir,
                            qiblah: _qiblah,
                            isDark: isDark,
                          ),
                        ),
                        // BBF logo overlay in center
                        Container(
                          width: size * 0.18,
                          height: size * 0.18,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(3.r),
                          child: Image.asset(
                            'assets/images/bbf-logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Direction card ───────────────────────────────────────────────
          _directionCard(isDark, green),
          SizedBox(height: 12.h),

          // ── Stats row ────────────────────────────────────────────────────
          _statsRow(isDark, green),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _locationCard(bool isDark, Color green) {
    final pos = _position;
    final coordText = pos != null
        ? '${pos.latitude.abs().toStringAsFixed(4)}° ${pos.latitude >= 0 ? 'N' : 'S'}'
            '  ${pos.longitude.abs().toStringAsFixed(4)}° ${pos.longitude >= 0 ? 'O' : 'W'}'
        : 'Standort wird ermittelt…';
    final country = _guessCountry();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? BColors.prayerRowDark : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.location_on_rounded, color: green, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dein Standort',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    coordText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  if (country != null)
                    Text(
                      country,
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/bbf-logo.png',
              width: 52.r,
              height: 52.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _directionCard(bool isDark, Color green) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            _kaabaWidget(44.r),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Richtung zur Kaaba',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${((_qiblah % 360 + 360) % 360).toStringAsFixed(0)}°',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: green,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _directionLabel(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(bool isDark, Color green) {
    final dist = _distanceKm;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _statCard(
            isDark: isDark,
            green: green,
            icon: Icons.gps_fixed_rounded,
            label: 'Genauigkeit',
            value: _accuracyLabel(),
          ),
          SizedBox(width: 8.w),
          _statCard(
            isDark: isDark,
            green: green,
            icon: Icons.navigation_rounded,
            label: 'Entfernung',
            value: dist != null ? _formatDistance(dist) : '–',
          ),
          SizedBox(width: 8.w),
          _statCard(
            isDark: isDark,
            green: green,
            icon: Icons.history_rounded,
            label: 'Letzte Update',
            value: _lastUpdateLabel(),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required Color green,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? BColors.prayerRowDark : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: green, size: 16.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style:
                  TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _kaabaWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _KaabaIconPainter(),
        ),
      ),
    );
  }
}

// ─── Compass painter ──────────────────────────────────────────────────────────

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

  Color get _green =>
      isDark ? const Color(0xFF4ADE80) : Colors.green;
  Color get _bg => isDark ? const Color(0xFF111827) : Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint();

    // Background
    paint
      ..color = _bg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, paint);

    // Compass face — rotates with device so N always tracks real North
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-direction * _deg);
    _drawIslamicStar(canvas, r);
    _drawFace(canvas, r);
    canvas.restore();

    // Qibla needle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-qiblah * _deg);
    _drawNeedle(canvas, r);
    canvas.restore();

    // Outer ring
    paint
      ..color = _green
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.022;
    canvas.drawCircle(center, r - r * 0.011, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawIslamicStar(Canvas canvas, double r) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.grey.shade400)
          .withOpacity(isDark ? 0.04 : 0.08)
      ..style = PaintingStyle.fill;

    final starR = r * 0.44;
    const spikes = 8;
    final path = Path();
    for (int i = 0; i < spikes * 2; i++) {
      final angle = i * pi / spikes - pi / 2;
      final radius = i.isEven ? starR : starR * 0.42;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawFace(Canvas canvas, double r) {
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * _deg;
      final isCardinal = i % 18 == 0;
      final isMedium = i % 6 == 0;

      final outerR = r * 0.93;
      final tickLen = isCardinal
          ? r * 0.11
          : isMedium
              ? r * 0.07
              : r * 0.04;

      tick
        ..color = isCardinal
            ? (isDark
                ? Colors.white.withOpacity(0.45)
                : Colors.grey.shade400)
            : isMedium
                ? (isDark
                    ? Colors.white.withOpacity(0.18)
                    : Colors.grey.shade300)
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200)
        ..strokeWidth = isCardinal ? 2.0 : isMedium ? 1.4 : 0.9;

      final s = sin(angle);
      final c = cos(angle);
      canvas.drawLine(
        Offset(outerR * s, -outerR * c),
        Offset((outerR - tickLen) * s, -(outerR - tickLen) * c),
        tick,
      );
    }

    // North indicator triangle
    final triPaint = Paint()
      ..color = _green
      ..style = PaintingStyle.fill;
    final triPath = Path()
      ..moveTo(0, -r * 0.895)
      ..lineTo(-r * 0.032, -r * 0.785)
      ..lineTo(r * 0.032, -r * 0.785)
      ..close();
    canvas.drawPath(triPath, triPaint);

    // Cardinal labels
    _drawLabel(canvas, 'N', 0, r,
        isDark ? Colors.white : const Color(0xFF1F2937), 18, FontWeight.bold);
    _drawLabel(canvas, 'E', pi / 2, r,
        isDark ? Colors.white54 : Colors.grey.shade500, 13, FontWeight.w600);
    _drawLabel(canvas, 'S', pi, r,
        isDark ? Colors.white54 : Colors.grey.shade500, 13, FontWeight.w600);
    _drawLabel(canvas, 'W', 3 * pi / 2, r,
        isDark ? Colors.white54 : Colors.grey.shade500, 13, FontWeight.w600);
  }

  void _drawLabel(Canvas canvas, String text, double angle, double r,
      Color color, double fontSize, FontWeight weight) {
    final labelR = r * 0.68;
    final x = labelR * sin(angle);
    final y = -labelR * cos(angle);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: weight,
            height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(direction * _deg);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _drawNeedle(Canvas canvas, double r) {
    final len = r * 0.72;
    final w = r * 0.055;
    final paint = Paint()..style = PaintingStyle.fill;

    // Counter-needle (gray)
    final counterPath = Path()
      ..moveTo(0, len * 0.52)
      ..lineTo(-w * 0.8, len * 0.12)
      ..lineTo(-w * 0.38, 0)
      ..lineTo(w * 0.38, 0)
      ..lineTo(w * 0.8, len * 0.12)
      ..close();
    paint.color = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    canvas.drawPath(counterPath, paint);
    paint
      ..color = isDark ? Colors.grey.shade600 : Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(counterPath, paint);
    paint.style = PaintingStyle.fill;

    // Drop shadow for green needle
    canvas.drawPath(
      Path()
        ..moveTo(0, -len)
        ..lineTo(-w, -len * 0.25)
        ..lineTo(-w * 0.4, 0)
        ..lineTo(w * 0.4, 0)
        ..lineTo(w, -len * 0.25)
        ..close(),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Green needle body
    final arrowPath = Path()
      ..moveTo(0, -len)
      ..lineTo(-w, -len * 0.25)
      ..lineTo(-w * 0.4, 0)
      ..lineTo(w * 0.4, 0)
      ..lineTo(w, -len * 0.25)
      ..close();

    paint.color =
        isDark ? const Color(0xFF166534) : const Color(0xFF15803D);
    canvas.drawPath(arrowPath, paint);

    // Highlight
    paint.color =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
    canvas.drawPath(
      Path()
        ..moveTo(0, -len)
        ..lineTo(-w, -len * 0.25)
        ..lineTo(0, -len * 0.25)
        ..close(),
      paint,
    );

    // Needle outline
    paint
      ..color = isDark
          ? const Color(0xFF14532D)
          : const Color(0xFF166534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(arrowPath, paint);
    paint.style = PaintingStyle.fill;

    // Kaaba marker at needle tip
    final kR = r * 0.09;
    final kCenter = Offset(0, -len - kR * 0.2);

    paint.color = Colors.white;
    canvas.drawCircle(kCenter, kR, paint);

    paint
      ..color = _green
      ..style = PaintingStyle.stroke
      ..strokeWidth = kR * 0.22;
    canvas.drawCircle(kCenter, kR * 0.87, paint);
    paint.style = PaintingStyle.fill;

    final kBW = kR * 0.78;
    final kBH = kR * 0.68;
    paint.color = const Color(0xFF1a1a1a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: kCenter, width: kBW, height: kBH),
        Radius.circular(kR * 0.1),
      ),
      paint,
    );

    paint.color = const Color(0xFFD4A017);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(kCenter.dx, kCenter.dy + kBH * 0.1),
        width: kBW * 0.28,
        height: kBH * 0.45,
      ),
      paint,
    );

    paint
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = kR * 0.09;
    canvas.drawLine(
      Offset(kCenter.dx - kBW * 0.4, kCenter.dy - kBH * 0.08),
      Offset(kCenter.dx + kBW * 0.4, kCenter.dy - kBH * 0.08),
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

// ─── Kaaba icon painter (for direction card) ──────────────────────────────────

class _KaabaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF1a1a1a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.1, w, h * 0.9),
        Radius.circular(w * 0.08),
      ),
      paint,
    );

    paint.color = const Color(0xFFD4A017);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.35, h * 0.48, w * 0.3, h * 0.52),
      paint,
    );

    paint
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.07;
    canvas.drawLine(Offset(0, h * 0.36), Offset(w, h * 0.36), paint);
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(_KaabaIconPainter old) => false;
}

// ─── Error view ───────────────────────────────────────────────────────────────

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
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72.sp, color: Colors.red.shade400),
            SizedBox(height: 20.h),
            Text(
              title,
              style:
                  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionLabel != null
                  ? Icons.settings_rounded
                  : Icons.refresh_rounded),
              label: Text(actionLabel ?? 'Erneut versuchen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
