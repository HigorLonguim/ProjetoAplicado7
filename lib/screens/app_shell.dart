import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'placeholder_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    PlaceholderScreen(
      title: 'Explorar',
      message: 'Aqui voce pode listar as principais features e fluxos da app.',
      icon: Icons.explore_outlined,
    ),
    PlaceholderScreen(
      title: 'Perfil',
      message: 'Espaco para dados do usuario, configuracoes e atalhos pessoais.',
      icon: Icons.person_outline,
    ),
  ];

  static const _items = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Explorar',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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