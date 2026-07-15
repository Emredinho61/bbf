import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a half-circle (top semicircle) progress arc with a soft glow
/// and a glowing dot at the leading tip of the progress.
///
/// Coordinate convention: the arc starts at 9 o'clock (left) and sweeps
/// clockwise through 12 o'clock (top) to 3 o'clock (right).
class GlowArcPainter extends CustomPainter {
  final double percent; // 0.0 → 1.0
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  const GlowArcPainter({
    required this.percent,
    required this.progressColor,
    required this.trackColor,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    // Inset radius so the stroke stays fully inside the canvas bounds.
    final r = cx - strokeWidth;

    // ── Track (background arc) ────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      pi,  // start: left (9 o'clock)
      pi,  // sweep clockwise through top to right
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = trackColor,
    );

    if (percent <= 0) return;
    final sweep = pi * percent;

    // ── Glow layers (widest/most transparent first) ───────────────────────
    for (int i = 2; i >= 1; i--) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        pi,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + i * 7.0
          ..strokeCap = StrokeCap.round
          ..color = progressColor.withOpacity(0.08 * i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 5.0),
      );
    }

    // ── Main progress arc ─────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      pi,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = progressColor,
    );

    // ── Tip dot ───────────────────────────────────────────────────────────
    // In Flutter's canvas (y-down, angles clockwise from right):
    //   tip angle = pi + sweep = pi*(1 + percent)
    //   position  = center + r*(cos θ, sin θ)
    final tipAngle = pi * (1 + percent);
    final tip = Offset(
      cx + r * cos(tipAngle),
      cy + r * sin(tipAngle),
    );
    final dotR = strokeWidth * 0.95;

    // Outer halo
    canvas.drawCircle(
      tip,
      dotR + 9,
      Paint()
        ..color = progressColor.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Inner halo
    canvas.drawCircle(
      tip,
      dotR + 4,
      Paint()
        ..color = progressColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // White ring
    canvas.drawCircle(tip, dotR, Paint()..color = Colors.white);
    // Colored core
    canvas.drawCircle(tip, dotR * 0.5, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(GlowArcPainter old) =>
      old.percent != percent ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor;
}
