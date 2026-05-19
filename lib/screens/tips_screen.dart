import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tips = [
      ('Como interpretar rótulos nutricionais', '2:45'),
      ('Por que o excesso de açúcar faz mal?', '3:10'),
      ('Sódio: vilão silencioso', '2:30'),
      ('Pão integral: escolhas mais saudáveis', '3:15'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Dicas de Saúde'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Aprenda com quem entende',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterChip(label: 'Todos', selected: true),
              _FilterChip(label: 'Rótulos'),
              _FilterChip(label: 'Alimentação'),
              _FilterChip(label: 'Saúde'),
            ],
          ),
          const SizedBox(height: 16),
          for (final tip in tips) ...[
            _VideoCard(title: tip.$1, duration: tip.$2),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(label),
      backgroundColor: selected ? colorScheme.primary : colorScheme.surface,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: colorScheme.outlineVariant),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.title, required this.duration});

  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.play_arrow_rounded, color: colorScheme.onPrimaryContainer, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(duration),
              ],
            ),
          ),
        ],
      ),
    );
  }
}