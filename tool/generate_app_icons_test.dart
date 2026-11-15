import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gera os ícones oficiais do aplicativo', () async {
    final targets = <String, int>{
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
      'web/icons/Icon-192.png': 192,
      'web/icons/Icon-512.png': 512,
      'web/icons/Icon-maskable-192.png': 192,
      'web/icons/Icon-maskable-512.png': 512,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': 167,
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png':
          1024,
    };

    for (final target in targets.entries) {
      await _writeIcon(target.key, target.value);
    }
  });
}

Future<void> _writeIcon(String path, int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final scale = size / 64;
  canvas.scale(scale, scale);

  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 64, 64),
    ui.Paint()..color = const ui.Color(0xFF203159),
  );
  canvas.drawOval(
    const ui.Rect.fromLTWH(16, 17, 34, 40),
    ui.Paint()
      ..color = const ui.Color(0xFFE89060)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 7,
  );

  final leaf = ui.Path()
    ..moveTo(31, 7)
    ..cubicTo(19, 9, 12, 17, 14, 28)
    ..cubicTo(16, 37, 24, 41, 34, 39)
    ..cubicTo(38, 38, 41, 37, 44, 34)
    ..cubicTo(35, 34, 29, 31, 25, 26)
    ..cubicTo(21, 21, 20, 16, 20, 10)
    ..cubicTo(24, 18, 30, 24, 38, 29)
    ..cubicTo(40, 20, 37, 12, 31, 7)
    ..close();
  canvas.drawPath(leaf, ui.Paint()..color = const ui.Color(0xFF78964A));

  final vein = ui.Path()
    ..moveTo(19, 17)
    ..cubicTo(24, 26, 32, 34, 44, 39);
  canvas.drawPath(
    vein,
    ui.Paint()
      ..color = const ui.Color(0xFF203159)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = ui.StrokeCap.round,
  );

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (bytes == null) throw StateError('Não foi possível gerar $path');
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
}
