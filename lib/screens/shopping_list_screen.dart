import 'package:flutter/material.dart';
import '../services/shopping_list_service.dart';
import '../models/shopping_list.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> with TickerProviderStateMixin {
  late ShoppingListService _service;
  late AnimationController _fabController;
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUnit = 'un';
  String _selectedBrand = '';

  static const _units = ['un', 'kg', 'l', 'ml', 'g', 'dz'];

  @override
  void initState() {
    super.initState();
    _service = ShoppingListService();
    _fabController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adicionar Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nome do produto',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: _selectedBrand),
                onChanged: (value) => _selectedBrand = value,
                decoration: InputDecoration(
                  hintText: 'Marca',
                  prefixIcon: const Icon(Icons.label_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Quantidade',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value ?? 'un'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
                    _service.addItem(
                      productName: _nameController.text,
                      productBrand: _selectedBrand.isEmpty ? 'Genérico' : _selectedBrand,
                      quantity: double.tryParse(_quantityController.text) ?? 1,
                      unit: _selectedUnit,
                    );

                    _nameController.clear();
                    _quantityController.clear();
                    _selectedBrand = '';
                    _selectedUnit = 'un';

                    Navigator.pop(context);
                    setState(() {});
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuggestions() {
    final suggestions = _service.getSuggestions();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sugestões',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions
                  .map(
                    (s) => ActionChip(
                      onPressed: () {
                        _service.addItem(
                          productName: s['name']!,
                          productBrand: s['brand']!,
                          quantity: 1,
                          unit: s['unit']!,
                        );
                        setState(() {});
                        Navigator.pop(context);
                      },
                      avatar: Text(s['icon']!),
                      label: Text('${s['name']} (${s['unit']})'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _service.getItemsSorted();
    final stats = _service.getStats();
    final estimatedTotal = _service.estimateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: items.isNotEmpty
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Limpar comprados'),
                      onTap: () {
                        _service.removeCheckedItems();
                        setState(() {});
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Limpar tudo'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Limpar lista?'),
                            content: const Text('Esta ação não pode ser desfeita.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                              TextButton(
                                onPressed: () {
                                  _service.clearList();
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Text('Limpar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              ]
            : null,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Lista vazia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione produtos para começar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar primeiro item'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Estatísticas
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${stats['total']}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text('Total', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${stats['pending']}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text('Faltam', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'R\$ ${estimatedTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text('Estimado', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${stats['percentage']}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text('Completo', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          _service.removeItem(item.id);
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Item removido'),
                              action: SnackBarAction(
                                label: 'Desfazer',
                                onPressed: () {
                                  _service.updateItem(item);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.delete, color: colorScheme.onError),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: item.checked ? colorScheme.surfaceContainerHighest : colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Checkbox(
                              value: item.checked,
                              onChanged: (_) {
                                _service.toggleItem(item.id);
                                setState(() {});
                              },
                            ),
                            title: Text(
                              item.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: item.checked ? TextDecoration.lineThrough : null,
                                color: item.checked ? colorScheme.onSurfaceVariant : null,
                              ),
                            ),
                            subtitle: Text(
                              item.productBrand,
                              style: TextStyle(
                                fontSize: 12,
                                color: item.checked ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: items.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _showSuggestions,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Sugestões'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      final listText = items
                          .where((i) => !i.checked)
                          .map((i) => '☐ ${i.productName} (${i.quantity} ${i.unit})')
                          .join('\n');

                      final message = 'Minha Lista de Compras:\n\n$listText\n\nEstimado: R\$ ${estimatedTotal.toStringAsFixed(2)}';

                      // Copiar para clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartilhamento em breve!')),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Compartilhar'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}