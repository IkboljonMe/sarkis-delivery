// One-off icon generator: renders the Sarko brand mark (gold badge +
// white wheat sheaf) to PNGs used as the Android launcher icon.
//
// Run with:  flutter test test/gen_icon_test.dart
// Outputs to /home/jan/Documents/SarkisBread/icon_out/.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _outDir = '/home/jan/Documents/SarkisBread/icon_out';

void main() {
  test('generate brand launcher icons', () async {
    Directory(_outDir).createSync(recursive: true);

    // Full badge: gold gradient rounded square + wheat (legacy / web icon).
    final badge = await _render(1024, withBackground: true, wheatFraction: 0.56);
    File('$_outDir/app_icon.png').writeAsBytesSync(badge);

    // Adaptive foreground: white wheat on transparent, kept inside the safe
    // zone (centered, ~46% of the canvas).
    final fg = await _render(1024, withBackground: false, wheatFraction: 0.46);
    File('$_outDir/wheat_fg.png').writeAsBytesSync(fg);
  });
}

Future<Uint8List> _render(double size,
    {required bool withBackground, required double wheatFraction}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Rect.fromLTWH(0, 0, size, size);

  if (withBackground) {
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE8B84B), Color(0xFFC8972A)],
    ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size * 0.22)),
      Paint()..shader = shader,
    );
  }

  final box = size * wheatFraction;
  final origin = Offset((size - box) / 2, (size - box) / 2);
  _paintWheat(canvas, box, origin, Colors.white);

  final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _paintWheat(Canvas canvas, double s, Offset o, Color color) {
  final cx = o.dx + s / 2;
  final stroke = Paint()
    ..color = color
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  canvas.drawLine(
      Offset(cx, o.dy + s * 0.18), Offset(cx, o.dy + s * 0.96), stroke);

  final grainLen = s * 0.30;
  final grainW = s * 0.13;
  for (var i = 0; i < 4; i++) {
    final y = o.dy + s * (0.22 + i * 0.18);
    _grain(canvas, fill, Offset(cx, y), grainLen, grainW, left: true);
    _grain(canvas, fill, Offset(cx, y), grainLen, grainW, left: false);
  }
  _topGrain(canvas, fill, Offset(cx, o.dy + s * 0.16), grainW * 1.1, s * 0.20);
}

void _grain(Canvas canvas, Paint paint, Offset base, double len, double width,
    {required bool left}) {
  final dir = left ? -1.0 : 1.0;
  final tip = Offset(base.dx + dir * len * 0.78, base.dy - len * 0.62);
  final mid = Offset((base.dx + tip.dx) / 2, (base.dy + tip.dy) / 2);
  final perp = Offset(dir * width * 0.5, width * 0.5);
  final path = Path()
    ..moveTo(base.dx, base.dy)
    ..quadraticBezierTo(mid.dx + perp.dx, mid.dy + perp.dy, tip.dx, tip.dy)
    ..quadraticBezierTo(mid.dx - perp.dx, mid.dy - perp.dy, base.dx, base.dy)
    ..close();
  canvas.drawPath(path, paint);
}

void _topGrain(
    Canvas canvas, Paint paint, Offset top, double width, double len) {
  final base = Offset(top.dx, top.dy + len);
  final path = Path()
    ..moveTo(base.dx, base.dy)
    ..quadraticBezierTo(top.dx + width, (top.dy + base.dy) / 2, top.dx, top.dy)
    ..quadraticBezierTo(top.dx - width, (top.dy + base.dy) / 2, base.dx, base.dy)
    ..close();
  canvas.drawPath(path, paint);
}
