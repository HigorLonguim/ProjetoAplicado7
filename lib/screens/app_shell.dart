import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'history_screen.dart';
import 'scanner_screen.dart';
import 'shopping_list_screen.dart';
import 'tips_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _items = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'Historico',
    ),
    NavigationDestination(
      icon: _ScannerNavIcon(isSelected: false),
      selectedIcon: _ScannerNavIcon(isSelected: true),
      label: 'Scanner',
    ),
    NavigationDestination(
      icon: Icon(Icons.play_circle_outline),
      selectedIcon: Icon(Icons.play_circle),
      label: 'Dicas',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: 'Lista',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const HistoryScreen(),
          // Se não for a aba do scanner, colocamos um espaço vazio
          // Isso força o ScannerScreen a dar dispose() quando você sai da aba
          // e rodar o initState()/inicializar a câmera quando você volta.
          _currentIndex == 2 ? const ScannerScreen() : const SizedBox.shrink(),
          const TipsScreen(),
          const ShoppingListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _items,
      ),
    );
  }
}

class _ScannerNavIcon extends StatelessWidget {
  const _ScannerNavIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.qr_code_scanner,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );
  }
}