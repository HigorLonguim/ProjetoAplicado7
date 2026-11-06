import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});
  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _filter = 'Todos';
  static const episodes = [
    _Episode(
      'Por onde começar a ler um rótulo?',
      'Rótulos',
      '12 min',
      'A ordem certa para entender porção, ingredientes e tabela nutricional.',
      Icons.document_scanner_outlined,
    ),
    _Episode(
      'Compra consciente sem complicação',
      'Compras',
      '18 min',
      'Como comparar produtos semelhantes e decidir com mais segurança.',
      Icons.shopping_basket_outlined,
    ),
    _Episode(
      'A lupa da Anvisa na prática',
      'Rótulos',
      '9 min',
      'O que significam os alertas de açúcar, sódio e gordura saturada.',
      Icons.search_rounded,
    ),
    _Episode(
      'Planejamento que cabe na rotina',
      'Nutrição',
      '22 min',
      'Estratégias simples para organizar refeições e reduzir desperdício.',
      Icons.calendar_month_outlined,
    ),
  ];

  void _open(_Episode episode) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  episode.icon,
                  color: AppColors.terracotta,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                episode.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${episode.category} • ${episode.duration}',
                style: const TextStyle(
                  color: AppColors.olive,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                episode.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.construction_rounded),
                  label: const Text('Episódio em produção'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Esta área prepara o formato de podcast e vídeo. Os episódios serão publicados com profissionais e fontes revisadas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = episodes
        .where((episode) => _filter == 'Todos' || episode.category == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Aprender')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyLight, AppColors.border],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: .18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.podcasts_rounded,
                    color: AppColors.peach,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Conversas que alimentam',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vídeos e podcasts curtos para entender rótulos, escolhas e alimentação.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.peach,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Origem Cast • em produção',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Todos', 'Rótulos', 'Nutrição', 'Compras']
                  .map(
                    (label) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _filter == label,
                        onSelected: (_) => setState(() => _filter = label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Próximos episódios',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const _ProductionBadge(),
            ],
          ),
          const SizedBox(height: 13),
          ...visible.map(
            (episode) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _open(episode),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.olive.withValues(alpha: .24),
                                AppColors.terracotta.withValues(alpha: .22),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            episode.icon,
                            color: AppColors.navy,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episode.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: .9,
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                episode.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 16,
                                    color: AppColors.olive,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    episode.duration,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionBadge extends StatelessWidget {
  const _ProductionBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.olive.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      'EM BREVE',
      style: TextStyle(
        fontSize: 9,
        letterSpacing: .7,
        color: AppColors.olive,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _Episode {
  const _Episode(
    this.title,
    this.category,
    this.duration,
    this.description,
    this.icon,
  );
  final String title;
  final String category;
  final String duration;
  final String description;
  final IconData icon;
}
