import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'discover_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
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
  void _select(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onOpenScanner: () => _select(2),
        onOpenPlanner: () => _select(1),
        onOpenTips: () => _select(3),
        onOpenHistory: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
      ),
      const MealPlannerScreen(),
      const ScannerScreen(key: ValueKey('scanner'), showBackButton: false),
      const TipsScreen(),
      const ShoppingListScreen(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Planejar',
            ),
            NavigationDestination(
              icon: _ScannerNavIcon(selected: false),
              selectedIcon: _ScannerNavIcon(selected: true),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: 'Aprender',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Lista',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerNavIcon extends StatelessWidget {
  const _ScannerNavIcon({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: selected
          ? const LinearGradient(colors: [AppColors.orange, AppColors.peach])
          : null,
      color: selected
          ? null
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.qr_code_scanner_rounded,
      color: selected
          ? AppColors.navy
          : Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
