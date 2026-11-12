import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _service = ShoppingListService();
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _service.initialize();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addItem() async {
    final result = await showModalBottomSheet<_NewItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddItemSheet(),
    );
    if (result == null) return;
    _service.addItem(
      productName: result.name,
      productBrand: result.brand,
      quantity: result.quantity,
      unit: result.unit,
    );
    setState(() {});
  }

  Future<void> _copyList() async {
    final pending = _service.currentList.items.where((item) => !item.checked);
    final text = [
      'Lista Origem',
      ...pending.map(
        (item) =>
            '- ${item.productName} — ${_formatQuantity(item.quantity)} ${item.unit}',
      ),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista copiada. Agora você pode colar onde quiser.'),
        ),
      );
    }
  }

  Future<void> _removeChecked(int count) async {
    if (count == 0) return;
    final confirmed = await _confirmCleanup(
      icon: Icons.check_circle_outline_rounded,
      title: 'Remover itens comprados?',
      message:
          '$count ${count == 1 ? 'item marcado será removido' : 'itens marcados serão removidos'} da lista.',
      actionLabel: 'Remover comprados',
    );
    if (!confirmed || !mounted) return;
    _service.removeCheckedItems();
    setState(() {});
  }

  Future<void> _clearList() async {
    final count = _service.currentList.items.length;
    if (count == 0) return;
    final confirmed = await _confirmCleanup(
      icon: Icons.delete_sweep_outlined,
      title: 'Limpar toda a lista?',
      message:
          'Os $count ${count == 1 ? 'item será removido' : 'itens serão removidos'}, inclusive os que ainda estão pendentes.',
      actionLabel: 'Limpar lista',
    );
    if (!confirmed || !mounted) return;
    _service.clearList();
    setState(() {});
  }

  Future<bool> _confirmCleanup({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      sheetContext,
                    ).colorScheme.errorContainer.withValues(alpha: .72),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(sheetContext).colorScheme.error,
                      foregroundColor: Theme.of(
                        sheetContext,
                      ).colorScheme.onError,
                    ),
                    onPressed: () => Navigator.pop(sheetContext, true),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(actionLabel),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  String _formatQuantity(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final items = _service.getItemsSorted();
    final checked = items.where((item) => item.checked).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha lista')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const OrigemMark(size: 82),
                    const SizedBox(height: 24),
                    Text(
                      'Sua lista está vazia',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione itens manualmente ou salve um produto depois de escaneá-lo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Adicionar primeiro item',
                      icon: Icons.add_rounded,
                      onPressed: _addItem,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.navyLight, AppColors.navy],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            value: '${items.length}',
                            label: 'itens',
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            value: '${items.length - checked}',
                            label: 'pendentes',
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            value:
                                '${items.isEmpty ? 0 : (checked / items.length * 100).round()}%',
                            label: 'concluída',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: checked == 0
                              ? null
                              : () => _removeChecked(checked),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(
                            checked == 0
                                ? 'Nenhum comprado'
                                : 'Remover comprados ($checked)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: .55),
                            ),
                          ),
                          onPressed: _clearList,
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: const Text('Limpar lista'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 22),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            _service.removeItem(item.id);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Item removido.'),
                                action: SnackBarAction(
                                  label: 'Desfazer',
                                  onPressed: () {
                                    _service.restoreItem(item);
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: CheckboxListTile(
                              value: item.checked,
                              onChanged: (_) {
                                _service.toggleItem(item.id);
                                setState(() {});
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              secondary: item.productImage == null
                                  ? null
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.productImage!,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                              title: Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: item.checked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                item.productBrand.isEmpty
                                    ? '${_formatQuantity(item.quantity)} ${item.unit}'
                                    : '${item.productBrand} • ${_formatQuantity(item.quantity)} ${item.unit}',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyList,
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('Copiar lista'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            label: 'Adicionar',
                            icon: Icons.add_rounded,
                            onPressed: _addItem,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );
}

class _NewItem {
  const _NewItem(this.name, this.brand, this.quantity, this.unit);
  final String name, brand, unit;
  final double quantity;
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();
  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  String _unit = 'un';
  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      6,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Adicionar item', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          TextFormField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Produto',
              prefixIcon: Icon(Icons.shopping_bag_outlined),
            ),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Informe o produto.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _brand,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Marca (opcional)',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  validator: (value) {
                    final number = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return number == null || number <= 0
                        ? 'Use um valor positivo.'
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Unidade'),
                  items: ['un', 'kg', 'g', 'l', 'ml', 'dz']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => _unit = value ?? 'un',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Adicionar à lista',
            icon: Icons.add_rounded,
            onPressed: () {
              if (!(_key.currentState?.validate() ?? false)) return;
              Navigator.pop(
                context,
                _NewItem(
                  _name.text.trim(),
                  _brand.text.trim(),
                  double.parse(_quantity.text.replaceAll(',', '.')),
                  _unit,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
