import 'dart:math' as math;
import 'package:flutter/material.dart';

class AvtoryLogo extends StatelessWidget {
  const AvtoryLogo({super.key, this.size = 88, this.showText = false, this.textScaleFactor});

  final double size;
  final bool showText;
  final double? textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CustomPaint(painter: _AvtoryLogoPainter()),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.25),
          RichText(
            textScaler: textScaleFactor != null ? TextScaler.linear(textScaleFactor!) : MediaQuery.textScalerOf(context),
            text: const TextSpan(children: [
              TextSpan(
                text: 'AVT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: 'ORY',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}

class _AvtoryLogoPainter extends CustomPainter {
  const _AvtoryLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    _drawBg(canvas, cx, cy, r);
    _drawPin(canvas, cx, cy, r);
    _drawWrench(canvas, cx, cy, r);
    _drawDots(canvas, cx, cy, r);
  }

  void _drawBg(Canvas canvas, double cx, double cy, double r) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r * 0.97, bgPaint);

    Paint()
      ..color = const Color(0xFF1E40AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.02;
    canvas.drawCircle(Offset(cx, cy), r * 0.97, Paint()..color = const Color(0xFF1E40AF)..style = PaintingStyle.stroke..strokeWidth = r * 0.02);

    final innerRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.006;
    canvas.drawCircle(Offset(cx, cy), r * 0.9, innerRing);

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7));
    canvas.drawPath(_dashPath(path, 6, 4), dashPaint);
  }

  Path _dashPath(Path source, double dashLength, double gapLength) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        dest.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        distance = next + gapLength;
      }
    }
    return dest;
  }

  void _drawPin(Canvas canvas, double cx, double cy, double r) {
    final s = r * 0.52;
    final top = cy - s * 0.7;
    final btm = cy + s * 1.1;
    final w = s * 0.52;

    final path = Path()
      ..moveTo(cx, btm)
      ..cubicTo(cx + w * 1.3, cy + s * 0.3, cx + w, top + s * 0.25, cx + w * 0.5, top)
      ..cubicTo(cx + w * 0.15, top - s * 0.08, cx - w * 0.15, top - s * 0.08, cx - w * 0.5, top)
      ..cubicTo(cx - w, top + s * 0.25, cx - w * 1.3, cy + s * 0.3, cx, btm)
      ..close();

    final pinPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ).createShader(path.getBounds());

    canvas.drawShadow(path, Colors.black26, 4, false);
    canvas.drawPath(path, pinPaint);

    Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    canvas.drawCircle(Offset(cx, cy - s * 0.22), s * 0.28, Paint()..color = Colors.white);
  }

  void _drawWrench(Canvas canvas, double cx, double cy, double r) {
    canvas.save();
    canvas.translate(cx - r * 0.05, cy - r * 0.37);
    canvas.rotate(-0.2);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = r * 0.055;

    final w = r * 0.25;
    final h = r * 0.25;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.1, h * 0.6)
        ..cubicTo(w * -0.05, h * 0.4, w * -0.05, h * 0.1, w * 0.1, h * -0.05)
        ..cubicTo(w * 0.25, h * -0.2, w * 0.5, h * -0.2, w * 0.65, h * -0.05)
        ..lineTo(w * 1.3, h * 0.6)
        ..lineTo(w * 1.15, h * 0.75)
        ..lineTo(w * 0.5, h * 0.1),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 1.5, h * -0.3)
        ..cubicTo(w * 1.7, h * -0.45, w * 1.95, h * -0.45, w * 2.1, h * -0.3)
        ..cubicTo(w * 2.25, h * -0.15, w * 2.25, h * 0.1, w * 2.1, h * 0.25)
        ..lineTo(w * 0.65, h * 1.7)
        ..lineTo(w * 0.35, h * 1.4),
      paint,
    );

    canvas.restore();
  }

  void _drawDots(Canvas canvas, double cx, double cy, double r) {
    final a = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final b = Paint()..color = Colors.white.withValues(alpha: 0.12);

    for (final (x, y, rad, p) in [
      (cx, cy - r * 0.9, 3.0, a),
      (cx, cy + r * 0.9, 3.0, b),
      (cx - r * 0.9, cy, 3.0, a),
      (cx + r * 0.9, cy, 3.0, a),
      (cx - r * 0.7, cy - r * 0.6, 2.0, b),
      (cx + r * 0.7, cy - r * 0.6, 2.0, b),
      (cx - r * 0.7, cy + r * 0.6, 2.0, b),
      (cx + r * 0.7, cy + r * 0.6, 2.0, b),
    ]) {
      canvas.drawCircle(Offset(x, y), rad, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
