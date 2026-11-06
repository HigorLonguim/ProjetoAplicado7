import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const OrigemApp());
}

class OrigemApp extends StatelessWidget {
  const OrigemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Origem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/brand/background.jpg', fit: BoxFit.cover),
          ColoredBox(color: AppColors.navy.withValues(alpha: .52)),
          child ?? const SizedBox.shrink(),
        ],
      ),
      home: const AppShell(),
    );
  }
}
