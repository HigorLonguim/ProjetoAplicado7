import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/shopping_list.dart';
import 'local_store.dart';

class ShoppingListService {
  static final ShoppingListService _instance = ShoppingListService._internal();
  factory ShoppingListService() => _instance;
  ShoppingListService._internal();
  static const _key = 'shopping_list_v1';
  final _store = LocalStore();
  bool _initialized = false;
  ShoppingList _currentList = ShoppingList(id: 'default', name: 'Minha lista', items: const [], createdAt: DateTime.now());
  ShoppingList get currentList => _currentList;

  Future<void> initialize() async {
    if (_initialized) return;
    final raw = await _store.getString(_key);
    if (raw != null) {
      try { _currentList = ShoppingList.fromJson(jsonDecode(raw) as Map<String, dynamic>); } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _save() async => _store.setString(_key, jsonEncode(_currentList.toJson()));
  void _commit(ShoppingList list) { _currentList = list.copyWith(updatedAt: DateTime.now()); unawaited(_save()); }

  void addItem({required String productName, required String productBrand, required double quantity, required String unit, String? productId, String? productImage}) {
    final item = ShoppingListItem(id: const Uuid().v4(), productId: productId ?? const Uuid().v4(), productName: productName.trim(), productBrand: productBrand.trim(), productImage: productImage, quantity: quantity, unit: unit, createdAt: DateTime.now());
    final existing = _currentList.items.where((value) => value.productId == item.productId).firstOrNull;
    if (existing != null) {
      _commit(_currentList.updateItem(existing.copyWith(quantity: existing.quantity + quantity)));
    } else {
      _commit(_currentList.addItem(item));
    }
  }
  void addItems(Iterable<({String name, String brand, double quantity, String unit})> values) {
    var list = _currentList;
    for (final value in values) {
      list = list.addItem(ShoppingListItem(
        id: const Uuid().v4(),
        productId: const Uuid().v4(),
        productName: value.name,
        productBrand: value.brand,
        quantity: value.quantity,
        unit: value.unit,
        createdAt: DateTime.now(),
      ));
    }
    _commit(list);
  }
  void removeItem(String id) => _commit(_currentList.removeItem(id));
  void restoreItem(ShoppingListItem item) => _commit(_currentList.addItem(item));
  void toggleItem(String id) => _commit(_currentList.toggleItemChecked(id));
  void clearList() => _commit(_currentList.clearItems());
  void removeCheckedItems() => _commit(_currentList.copyWith(items: _currentList.items.where((item) => !item.checked).toList()));
  List<ShoppingListItem> getItemsSorted() => [..._currentList.items]..sort((a, b) => a.checked == b.checked ? a.createdAt.compareTo(b.createdAt) : (a.checked ? 1 : -1));
}
