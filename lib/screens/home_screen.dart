import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
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

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _history = HistoryService().getItems();
  }

  Future<void> _openAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(_refresh),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Minha conta',
                  onPressed: _openAccount,
                  icon: const Icon(Icons.person_outline_rounded),
                ),
                const Spacer(),
                const OrigemMark(size: 48),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyLight, AppColors.border],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: .22),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 620;
                  final text = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SEU GUIA DE RÓTULOS',
                        style: TextStyle(
                          color: AppColors.peach,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Escolhas mais claras começam pela origem.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Escaneie um produto para entender sua composição, comparar informações e decidir com mais segurança.',
                        style: TextStyle(color: Colors.white70, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeroBenefit(
                            icon: Icons.calendar_month_rounded,
                            label: 'Planejar',
                            color: AppColors.olive,
                            onTap: widget.onOpenPlanner,
                          ),
                          _HeroBenefit(
                            icon: Icons.school_rounded,
                            label: 'Aprender',
                            color: AppColors.orange,
                            onTap: widget.onOpenTips,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.orange, AppColors.peach],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: FilledButton.icon(
                          onPressed: widget.onOpenScanner,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text(
                            'Escanear produto',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  );
                  final illustration = Container(
                    width: wide ? 330 : constraints.maxWidth,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.orange.withValues(alpha: .28),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/brand/origem_wordmark_user.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'Assinatura visual Origem',
                      ),
                    ),
                  );
                  return wide
                      ? Row(
                          children: [
                            Expanded(child: text),
                            const SizedBox(width: 20),
                            illustration,
                          ],
                        )
                      : Column(
                          children: [
                            text,
                            const SizedBox(height: 22),
                            illustration,
                          ],
                        );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  'Últimas consultas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onOpenHistory,
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<HistoryItem>>(
              future: _history,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (items.isEmpty) {
                  return const _EmptyHistory();
                }
                return Column(
                  children: items
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryTile(item: item),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBenefit extends StatelessWidget {
  const _HeroBenefit({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: .16),
    shape: StadiumBorder(side: BorderSide(color: color.withValues(alpha: .7))),
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 15),
          ],
        ),
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: AppColors.olive,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Seus produtos consultados aparecerão aqui.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final HistoryItem item;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: item.productImage == null
              ? const ColoredBox(
                  color: Color(0xFFE9E7DF),
                  child: Icon(Icons.inventory_2_outlined),
                )
              : Image.network(
                  item.productImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.inventory_2_outlined),
                ),
        ),
      ),
      title: Text(
        item.productName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        item.productBrand,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
