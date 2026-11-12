import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});
  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'Todos';
  late final AnimationController _intro;
  static const episodes = [
    _Episode(
      'Muzy compartilha dicas incríveis sobre alimentação',
      'Nutrição',
      'YouTube',
      'Uma conversa sobre alimentação e escolhas possíveis para o dia a dia.',
      Icons.restaurant_rounded,
      youtubeId: 'qTH_P4PBEI8',
      author: 'TICARACATICAST Cortes[OFICIAL]',
    ),
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

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _intro.value = 1;
      } else {
        _intro.forward();
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _launchVideo(_Episode episode) async {
    final url = episode.youtubeUrl;
    if (url == null) return;
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
      );
    }
  }

  void _open(_Episode episode) {
    if (episode.isPublished) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _VideoPlayerScreen(
            episode: episode,
            onOpenExternal: () => _launchVideo(episode),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (episode.isPublished)
                _VideoCover(episode: episode)
              else
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
              if (episode.author != null) ...[
                const SizedBox(height: 5),
                Text(
                  episode.author!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              Text(
                episode.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: episode.isPublished
                      ? () {
                          Navigator.pop(context);
                          _launchVideo(episode);
                        }
                      : null,
                  icon: Icon(
                    episode.isPublished
                        ? Icons.play_arrow_rounded
                        : Icons.construction_rounded,
                  ),
                  label: Text(
                    episode.isPublished
                        ? 'Assistir no YouTube'
                        : 'Publicação em preparação',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                episode.isPublished
                    ? 'O vídeo será aberto no YouTube. Os próximos conteúdos da faculdade poderão ser adicionados neste mesmo formato.'
                    : 'Este episódio do Origem já foi gravado e está sendo preparado para publicação.',
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

  ThemeData _learningTheme(BuildContext context) {
    final base = Theme.of(context);
    const lightText = AppColors.ink;
    const secondaryText = Color(0xFFD8DEE8);
    final scheme = base.colorScheme.copyWith(
      surface: AppColors.navyLight,
      onSurface: lightText,
      onSurfaceVariant: secondaryText,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: scheme,
      textTheme: base.textTheme.apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.navy,
        foregroundColor: lightText,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: lightText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.navyLight,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.navyLight,
        selectedColor: AppColors.olive.withValues(alpha: .18),
        labelStyle: const TextStyle(color: lightText),
        secondaryLabelStyle: const TextStyle(
          color: lightText,
          fontWeight: FontWeight.w800,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = episodes
        .where((episode) => _filter == 'Todos' || episode.category == _filter)
        .toList();
    return Theme(
      data: _learningTheme(context),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Aprender')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              _LearnReveal(
                animation: _intro,
                start: 0,
                child: Container(
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
                      Row(
                        children: [
                          const Expanded(
                            child: OrigemSecondaryWordmark(height: 52),
                          ),
                          const SizedBox(width: 18),
                          _PodcastSignal(animation: _intro),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Vozes que alimentam escolhas.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nossa primeira temporada já foi gravada. Enquanto preparamos a publicação, conheça os temas e acompanhe o conteúdo em destaque.',
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
                            'ORIGEM PODCASTS • TEMPORADA 01',
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
              ),
              const SizedBox(height: 22),
              _LearnReveal(
                animation: _intro,
                start: .16,
                child: SizedBox(
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
                              onSelected: (_) =>
                                  setState(() => _filter = label),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Destaque e episódios da temporada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  const _AvailableBadge(),
                ],
              ),
              const SizedBox(height: 13),
              ...visible.asMap().entries.map(
                (entry) => _LearnReveal(
                  animation: _intro,
                  start: (.3 + entry.key * .07).clamp(.3, .68),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: entry.value.isPublished
                        ? _PublishedVideoCard(
                            episode: entry.value,
                            onTap: () => _open(entry.value),
                          )
                        : _UpcomingEpisodeCard(
                            episode: entry.value,
                            onTap: () => _open(entry.value),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnReveal extends StatelessWidget {
  const _LearnReveal({
    required this.animation,
    required this.start,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final end = (start + .34).clamp(0.0, 1.0);
      final value = Curves.easeOutCubic.transform(
        Interval(start, end).transform(animation.value),
      );
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      );
    },
  );
}

class _PodcastSignal extends StatelessWidget {
  const _PodcastSignal({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final value = Curves.easeOutCubic.transform(
        const Interval(.08, .48).transform(animation.value),
      );
      return Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.apricot.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.apricot.withValues(alpha: .35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final height in [14.0, 30.0, 22.0, 34.0, 17.0]) ...[
              Container(
                width: 3,
                height: 4 + (height - 4) * value,
                decoration: BoxDecoration(
                  color: AppColors.warmYellow,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 3),
            ],
          ],
        ),
      );
    },
  );
}

class _VideoPlayerScreen extends StatefulWidget {
  const _VideoPlayerScreen({
    required this.episode,
    required this.onOpenExternal,
  });

  final _Episode episode;
  final VoidCallback onOpenExternal;

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.episode.youtubeId!,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        interfaceLanguage: 'pt',
        captionLanguage: 'pt',
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('Assistir'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Container(
            color: Colors.black,
            child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.olive.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    widget.episode.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  widget.episode.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.episode.author != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.episode.author!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  widget.episode.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: AppColors.peach,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A reprodução acontece dentro do Origem usando o player oficial do YouTube.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onOpenExternal,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Abrir no YouTube'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.olive.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      '1 DISPONÍVEL',
      style: TextStyle(
        fontSize: 9,
        letterSpacing: .7,
        color: AppColors.olive,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _PublishedVideoCard extends StatelessWidget {
  const _PublishedVideoCard({required this.episode, required this.onTap});
  final _Episode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VideoCover(episode: episode),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'VÍDEO DISPONÍVEL',
                        style: TextStyle(
                          color: AppColors.peach,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.olive,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  episode.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  episode.author ?? 'YouTube',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _UpcomingEpisodeCard extends StatelessWidget {
  const _UpcomingEpisodeCard({required this.episode, required this.onTap});
  final _Episode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
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
              child: Icon(episode.icon, color: AppColors.navy, size: 29),
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
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.olive,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${episode.duration} • publicação em preparação',
                        style: Theme.of(context).textTheme.bodySmall,
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
  );
}

class _VideoCover extends StatelessWidget {
  const _VideoCover({required this.episode});
  final _Episode episode;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          episode.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.navy,
            child: Icon(
              Icons.video_library_outlined,
              size: 50,
              color: AppColors.peach,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: .42)],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 36,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Episode {
  const _Episode(
    this.title,
    this.category,
    this.duration,
    this.description,
    this.icon, {
    this.youtubeId,
    this.author,
  });
  final String title;
  final String category;
  final String duration;
  final String description;
  final IconData icon;
  final String? youtubeId;
  final String? author;

  bool get isPublished => youtubeId != null;
  String? get youtubeUrl =>
      youtubeId == null ? null : 'https://www.youtube.com/watch?v=$youtubeId';
  String? get thumbnailUrl => youtubeId == null
      ? null
      : 'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg';
}
