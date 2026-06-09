import 'package:uuid/uuid.dart';
import '../models/shopping_list.dart';

/// Serviço para gerenciar a lista de compras em memória
/// Futuramente pode ser integrado com SharedPreferences ou backend
class ShoppingListService {
  static final ShoppingListService _instance = ShoppingListService._internal();

  factory ShoppingListService() {
    return _instance;
  }

  ShoppingListService._internal();

  ShoppingList _currentList = ShoppingList(
    id: 'default',
    name: 'Minha Lista de Compras',
    items: [],
    createdAt: DateTime.now(),
  );

  ShoppingList get currentList => _currentList;

  /// Adiciona um item à lista
  void addItem({
    required String productName,
    required String productBrand,
    required double quantity,
    required String unit,
    String? productId,
    String? productImage,
  }) {
    final item = ShoppingListItem(
      id: const Uuid().v4(),
      productId: productId ?? const Uuid().v4(),
      productName: productName,
      productBrand: productBrand,
      productImage: productImage,
      quantity: quantity,
      unit: unit,
      checked: false,
      createdAt: DateTime.now(),
    );

    _currentList = _currentList.addItem(item);
  }

  /// Remove um item
  void removeItem(String itemId) {
    _currentList = _currentList.removeItem(itemId);
  }

  /// Marca/desmarca item como comprado
  void toggleItem(String itemId) {
    _currentList = _currentList.toggleItemChecked(itemId);
  }

  /// Atualiza item existente
  void updateItem(ShoppingListItem item) {
    _currentList = _currentList.updateItem(item);
  }

  /// Atualiza quantidade de um item
  void updateItemQuantity(String itemId, double quantity) {
    final item = _currentList.items.firstWhere((i) => i.id == itemId);
    _currentList = _currentList.updateItem(item.copyWith(quantity: quantity));
  }

  /// Atualiza unidade de um item
  void updateItemUnit(String itemId, String unit) {
    final item = _currentList.items.firstWhere((i) => i.id == itemId);
    _currentList = _currentList.updateItem(item.copyWith(unit: unit));
  }

  /// Limpa a lista
  void clearList() {
    _currentList = _currentList.clearItems();
  }

  /// Remove itens comprados
  void removeCheckedItems() {
    final uncheckedItems = _currentList.items.where((i) => !i.checked).toList();
    _currentList = _currentList.copyWith(items: uncheckedItems);
  }

  /// Obtém estatísticas
  Map<String, dynamic> getStats() {
    final total = _currentList.items.length;
    final checked = _currentList.items.where((i) => i.checked).length;
    final pending = total - checked;

    return {
      'total': total,
      'checked': checked,
      'pending': pending,
      'percentage': total > 0 ? (checked / total * 100).toStringAsFixed(0) : '0',
    };
  }

  /// Agrupa itens por marca
  Map<String, List<ShoppingListItem>> getItemsGroupedByBrand() {
    final grouped = <String, List<ShoppingListItem>>{};

    for (final item in _currentList.items) {
      if (!grouped.containsKey(item.productBrand)) {
        grouped[item.productBrand] = [];
      }
      grouped[item.productBrand]!.add(item);
    }

    return grouped;
  }

  /// Agrupa itens (não comprados primeiro)
  List<ShoppingListItem> getItemsSorted() {
    final items = List<ShoppingListItem>.from(_currentList.items);
    items.sort((a, b) {
      // Não comprados primeiro
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      }
      // Depois por marca
      return a.productBrand.compareTo(b.productBrand);
    });
    return items;
  }

  /// Estima valor total (baseado em média de mercado)
  /// Esta é uma estimativa simples - pode ser refinada com dados reais
  double estimateTotal() {
    // Preços médios aproximados por unidade
    const priceMap = {
      'un': 5.0,    // unidade
      'kg': 15.0,   // quilo
      'l': 8.0,     // litro
      'ml': 0.05,   // mililitro
      'g': 0.015,   // grama
      'dz': 20.0,   // dúzia
    };

    double total = 0;
    for (final item in _currentList.items) {
      final basePrice = priceMap[item.unit] ?? 5.0;
      total += basePrice * item.quantity;
    }

    return total;
  }

  /// Retorna sugestões (favoritos/frequentes)
  List<Map<String, String>> getSuggestions() {
    return [
      {'name': 'Leite', 'brand': 'Integral', 'unit': 'l', 'icon': '🥛'},
      {'name': 'Pão', 'brand': 'Francês', 'unit': 'un', 'icon': '🍞'},
      {'name': 'Ovos', 'brand': 'Vermelhos', 'unit': 'dz', 'icon': '🥚'},
      {'name': 'Frutas', 'brand': 'Mistas', 'unit': 'kg', 'icon': '🍎'},
      {'name': 'Arroz', 'brand': 'Integral', 'unit': 'kg', 'icon': '🍚'},
      {'name': 'Feijão', 'brand': 'Preto', 'unit': 'kg', 'icon': '🫘'},
    ];
  }

  /// Restaura lista padrão (demo)
  void resetToDefault() {
    _currentList = ShoppingList(
      id: 'default',
      name: 'Minha Lista de Compras',
      items: [],
      createdAt: DateTime.now(),
    );
  }
}
