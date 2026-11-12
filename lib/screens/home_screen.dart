import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/origem_product_reveal.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenScanner,
    required this.onOpenPlanner,
    required this.onOpenTips,
    required this.onOpenHistory,
  });
  final VoidCallback onOpenScanner;
  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenTips;
  final VoidCallback onOpenHistory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HistoryItem>> _history;
  final _scroll = ScrollController();
  final _revealController = OrigemProductRevealController();
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
    _scroll.addListener(() {
      final next = _scroll.offset.clamp(0.0, 160.0);
      if (next != _offset) setState(() => _offset = next);
    });
  }

  void _refresh() => _history = HistoryService().getItems();

  void _openScanner() {
    _revealController.completePresentation();
    widget.onOpenScanner();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => setState(_refresh),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: _EditorialHero(
                  parallax: reduceMotion ? 0 : (_offset / 160).clamp(0, 1),
                  onScan: _openScanner,
                  onHistory: widget.onOpenHistory,
                  onAccount: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                    setState(_refresh);
                  },
                  revealController: _revealController,
                ),
              ),
              SliverToBoxAdapter(
                child: _EditorialPaths(
                  onPlan: widget.onOpenPlanner,
                  onLearn: widget.onOpenTips,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 44, 22, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Últimas leituras',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onOpenHistory,
                        child: const Text('Ver histórico'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<HistoryItem>>(
                  future: _history,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _HistoryLoading();
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return _EmptyHistory(onScan: _openScanner);
                    }
                    return SizedBox(
                      height: 178,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.take(6).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, index) =>
                            _HistoryTile(item: items[index]),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onHistory, required this.onAccount});
  final VoidCallback onHistory;
  final VoidCallback onAccount;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: onHistory,
        tooltip: 'Histórico de leituras',
        icon: const Icon(Icons.history_rounded),
        style: IconButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(48, 48),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        onPressed: onAccount,
        tooltip: 'Minha conta',
        icon: const Icon(Icons.person_outline_rounded),
        style: IconButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(48, 48),
        ),
      ),
    ],
  );
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.parallax,
    required this.onScan,
    required this.onHistory,
    required this.onAccount,
    required this.revealController,
  });
  final double parallax;
  final VoidCallback onScan;
  final VoidCallback onHistory;
  final VoidCallback onAccount;
  final OrigemProductRevealController revealController;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final compact = constraints.maxWidth < 360;
      final titleStyle =
          (wide
                  ? Theme.of(context).textTheme.displayLarge
                  : Theme.of(context).textTheme.headlineLarge)
              ?.copyWith(fontSize: wide ? 78 : 48);
      final copy = Padding(
        padding: EdgeInsets.fromLTRB(
          wide ? 56 : 22,
          wide ? 38 : (compact ? 68 : 42),
          wide ? 24 : 22,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _Eyebrow(),
            const SizedBox(height: 18),
            Text('Veja além\ndo rótulo.', style: titleStyle),
            const SizedBox(height: 18),
            Text(
              'Escaneie produtos, entenda os dados disponíveis e transforme informação em uma semana mais simples.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.sand),
              maxLines: wide ? 3 : 4,
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Escanear produto'),
            ),
          ],
        ),
      );
      final object = Transform.translate(
        offset: Offset(0, -18 * parallax),
        child: OrigemProductReveal(controller: revealController),
      );
      return SizedBox(
        height: wide ? 620 : (compact ? 710 : 670),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: const _BarcodeLinePainter()),
            ),
            if (wide)
              Row(
                children: [
                  Expanded(flex: 5, child: copy),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 42, 10),
                      child: object,
                    ),
                  ),
                ],
              )
            else ...[
              Positioned(
                left: 10,
                right: 10,
                top: compact ? 292 : 255,
                height: 400,
                child: object,
              ),
              Positioned(left: 0, right: 0, top: 0, child: copy),
            ],
            Positioned(
              top: wide ? 14 : 6,
              right: wide ? 42 : 22,
              child: _Header(onHistory: onHistory, onAccount: onAccount),
            ),
          ],
        ),
      );
    },
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 34,
        child: Divider(color: AppColors.apricot, thickness: 2),
      ),
      SizedBox(width: 10),
      Text(
        'INTELIGÊNCIA ALIMENTAR',
        style: TextStyle(
          color: AppColors.apricot,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    ],
  );
}

class _BarcodeLinePainter extends CustomPainter {
  const _BarcodeLinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * .68)
      ..cubicTo(
        size.width * .2,
        size.height * .58,
        size.width * .58,
        size.height * .82,
        size.width,
        size.height * .56,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.sage.withValues(alpha: .24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final paint = Paint()..color = AppColors.apricot.withValues(alpha: .42);
    for (var i = 0; i < 14; i++) {
      final x = size.width * .72 + i * (size.width * .018);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * .55, i.isEven ? 2 : 1, 22 + (i % 4) * 7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EditorialPaths extends StatelessWidget {
  const _EditorialPaths({required this.onPlan, required this.onLearn});
  final VoidCallback onPlan, onLearn;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 620;
        final first = _Path(
          ordinal: '01',
          title: 'Monte sua semana',
          subtitle: 'Uma jornada em nove escolhas, do prato à lista.',
          color: AppColors.sage,
          onTap: onPlan,
        );
        final second = _Path(
          ordinal: '02',
          title: 'Aprenda a escolher',
          subtitle: 'Conteúdo editorial sobre rótulos, nutrição e compras.',
          color: AppColors.warmYellow,
          onTap: onLearn,
        );
        if (wide) {
          return Row(
            children: [
              Expanded(child: first),
              const SizedBox(width: 18),
              Expanded(child: second),
            ],
          );
        }
        return Column(children: [first, const SizedBox(height: 12), second]);
      },
    ),
  );
}

class _Path extends StatelessWidget {
  const _Path({
    required this.ordinal,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final String ordinal, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        height: 168,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  ordinal,
                  style: const TextStyle(
                    color: AppColors.petroleum,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: AppColors.petroleum,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.petroleum,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.deepSage, height: 1.35),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final HistoryItem item;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: ColoredBox(
              color: AppColors.mineral,
              child: SizedBox.expand(
                child: item.productImage == null
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.deepSage,
                        size: 36,
                      )
                    : Image.network(
                        item.productImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.deepSage,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          item.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          item.productBrand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onScan});
  final VoidCallback onScan;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.sage, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.line_axis_rounded, color: AppColors.sage, size: 34),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sua linha começa aqui',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leia um produto para criar seu histórico.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onScan, child: const Text('Escanear')),
        ],
      ),
    ),
  );
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(child: CircularProgressIndicator(color: AppColors.sage)),
  );
}
