import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() => runApp(const OrigemApp());

class OrigemApp extends StatelessWidget {
  const OrigemApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Origem',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    builder: (context, child) => ColoredBox(
      color: AppColors.petroleum,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: CustomPaint(painter: _AtmospherePainter()),
          ),
          child ?? const SizedBox.shrink(),
        ],
      ),
    ),
    home: const AppShell(),
  );
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.petroleum);
    canvas.drawCircle(
      Offset(size.width * .88, size.height * .08),
      size.shortestSide * .38,
      Paint()
        ..color = AppColors.deepSage.withValues(alpha: .34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110),
    );
    canvas.drawCircle(
      Offset(size.width * .08, size.height * .82),
      size.shortestSide * .26,
      Paint()
        ..color = AppColors.apricot.withValues(alpha: .08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
