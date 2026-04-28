import 'package:flutter/material.dart';

import 'screens/app_shell.dart';

void main() {
  runApp(const OrigemApp());
}

class OrigemApp extends StatelessWidget {
  const OrigemApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Origem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const AppShell(),
    );
  }
}
