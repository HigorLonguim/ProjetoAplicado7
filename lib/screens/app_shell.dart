import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
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
  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  void _scan() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 420),
        reverseTransitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => const ScannerScreen(),
        transitionsBuilder: (_, animation, _, child) {
          if (reduceMotion) return child;
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              alignment: Alignment.bottomCenter,
              scale: Tween<double>(begin: .86, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  List<Widget> get _pages => [
    HomeScreen(
      onOpenScanner: _scan,
      onOpenPlanner: () => _select(1),
      onOpenTips: () => _select(3),
      onOpenHistory: () => _push(const HistoryScreen()),
    ),
    const MealPlannerScreen(),
    const ShoppingListScreen(),
    const TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 900;
      final content = AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.standard,
        switchInCurve: AppMotion.curve,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      );
      if (desktop) {
        return Scaffold(
          body: Row(
            children: [
              _DesktopRail(
                selected: _currentIndex,
                onSelect: _select,
                onScan: _scan,
              ),
              Expanded(child: content),
            ],
          ),
        );
      }
      return Scaffold(
        extendBody: true,
        body: content,
        bottomNavigationBar: _MobileDock(
          selected: _currentIndex,
          onSelect: _select,
          onScan: _scan,
        ),
      );
    },
  );
}

const _destinations = [
  (Icons.radar_rounded, 'Hoje'),
  (Icons.calendar_view_week_rounded, 'Planejar'),
  (Icons.shopping_bag_outlined, 'Lista'),
  (Icons.podcasts_rounded, 'Aprender'),
];

class _MobileDock extends StatelessWidget {
  const _MobileDock({
    required this.selected,
    required this.onSelect,
    required this.onScan,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    child: SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            top: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.petroleumRaised.withValues(alpha: .97),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: .7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .28),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: _DockItem(
                        index: i,
                        selected: selected == i,
                        onTap: () => onSelect(i),
                      ),
                    ),
                  const SizedBox(width: 68),
                  for (var i = 2; i < 4; i++)
                    Expanded(
                      child: _DockItem(
                        index: i,
                        selected: selected == i,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Semantics(
              button: true,
              label: 'Escanear produto',
              child: IconButton.filled(
                tooltip: 'Escanear produto',
                onPressed: onScan,
                style: IconButton.styleFrom(
                  minimumSize: const Size(62, 62),
                  backgroundColor: AppColors.apricot,
                  foregroundColor: AppColors.petroleum,
                  side: const BorderSide(color: AppColors.warmYellow, width: 2),
                  shadowColor: AppColors.apricot,
                  elevation: 8,
                ),
                icon: const Icon(Icons.document_scanner_outlined, size: 28),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final destination = _destinations[index];
    return Semantics(
      selected: selected,
      button: true,
      label: destination.$2,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                destination.$1,
                size: 22,
                color: selected ? AppColors.sage : AppColors.muted,
              ),
              const SizedBox(height: 3),
              Text(
                destination.$2,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.mineral : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopRail extends StatefulWidget {
  const _DesktopRail({
    required this.selected,
    required this.onSelect,
    required this.onScan,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;
  @override
  State<_DesktopRail> createState() => _DesktopRailState();
}

class _DesktopRailState extends State<_DesktopRail> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => expanded = true),
    onExit: (_) => setState(() => expanded = false),
    child: AnimatedContainer(
      duration: AppMotion.micro,
      width: expanded ? 210 : 88,
      color: AppColors.petroleumRaised,
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          OrigemMark(size: 46),
          const Spacer(),
          for (var i = 0; i < _destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Tooltip(
                message: _destinations[i].$2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onSelect(i),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: AppMotion.micro,
                      height: 54,
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 14 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: widget.selected == i
                            ? AppColors.deepSage
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: expanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            _destinations[i].$1,
                            color: widget.selected == i
                                ? AppColors.sage
                                : AppColors.muted,
                          ),
                          if (expanded) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _destinations[i].$2,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: FilledButton(
              onPressed: widget.onScan,
              style: FilledButton.styleFrom(
                padding: expanded
                    ? const EdgeInsets.symmetric(horizontal: 18)
                    : EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    const Text('Escanear'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
