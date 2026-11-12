import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.itemsLoader, this.onOpenProduct});

  final Future<List<HistoryItem>> Function()? itemsLoader;
  final ValueChanged<HistoryItem>? onOpenProduct;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryItem>> _items;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _items = widget.itemsLoader?.call() ?? HistoryService().getItems();
  }

  void _openProduct(HistoryItem item) {
    final callback = widget.onOpenProduct;
    if (callback != null) {
      callback(item);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoadingScreen(barcode: item.productId)),
    );
  }

  String _date(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'agora';
    if (difference.inHours < 1) return 'há ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'há ${difference.inHours} h';
    if (difference.inDays == 1) return 'ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Histórico'),
      actions: [
        IconButton(
          tooltip: 'Limpar histórico',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Limpar histórico?'),
                content: const Text(
                  'As consultas registradas neste dispositivo serão removidas.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await HistoryService().clear();
              setState(_reload);
            }
          },
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
    ),
    body: FutureBuilder<List<HistoryItem>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 70,
                    color: AppColors.olive,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Nenhuma consulta ainda',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Os produtos escaneados aparecerão aqui.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 7,
                ),
                onTap: () => _openProduct(item),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 50,
                    height: 50,
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
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.productBrand} • ${_date(item.scannedAt)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          },
        );
      },
    ),
  );
}
