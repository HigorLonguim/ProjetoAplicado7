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
  ShoppingList _currentList = ShoppingList(
    id: 'default',
    name: 'Minha lista',
    items: const [],
    createdAt: DateTime.now(),
  );
  ShoppingList get currentList => _currentList;

  Future<void> initialize() async {
    if (_initialized) return;
    final raw = await _store.getString(_key);
    if (raw != null) {
      try {
        _currentList = ShoppingList.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _save() async =>
      _store.setString(_key, jsonEncode(_currentList.toJson()));
  void _commit(ShoppingList list) {
    _currentList = list.copyWith(updatedAt: DateTime.now());
    unawaited(_save());
  }

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
      productName: productName.trim(),
      productBrand: productBrand.trim(),
      productImage: productImage,
      quantity: quantity,
      unit: unit,
      createdAt: DateTime.now(),
    );
    final existing = _currentList.items
        .where((value) => value.productId == item.productId)
        .firstOrNull;
    if (existing != null) {
      _commit(
        _currentList.updateItem(
          existing.copyWith(quantity: existing.quantity + quantity),
        ),
      );
    } else {
      _commit(_currentList.addItem(item));
    }
  }

  void addItems(
    Iterable<({String name, String brand, double quantity, String unit})>
    values,
  ) {
    var list = _currentList;
    for (final value in values) {
      list = list.addItem(
        ShoppingListItem(
          id: const Uuid().v4(),
          productId: const Uuid().v4(),
          productName: value.name,
          productBrand: value.brand,
          quantity: value.quantity,
          unit: value.unit,
          createdAt: DateTime.now(),
        ),
      );
    }
    _commit(list);
  }

  void addOrMergeItems(
    Iterable<({String name, String brand, double quantity, String unit})>
    values,
  ) {
    var list = _currentList;
    for (final value in values) {
      final key = '${_normalize(value.name)}|${_normalize(value.unit)}';
      final existing = list.items.where((item) {
        final itemKey =
            '${_normalize(item.productName)}|${_normalize(item.unit)}';
        return itemKey == key;
      }).firstOrNull;
      if (existing != null) {
        list = list.updateItem(
          existing.copyWith(
            quantity: existing.quantity + value.quantity,
            checked: false,
            productBrand: value.brand,
          ),
        );
      } else {
        list = list.addItem(
          ShoppingListItem(
            id: const Uuid().v4(),
            productId: 'planned-$key',
            productName: value.name,
            productBrand: value.brand,
            quantity: value.quantity,
            unit: value.unit,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    _commit(list);
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9áàãâäéèêëíìîïóòõôöúùûüç]+'), ' ')
      .trim();

  static String _alphabeticalKey(String value) => _normalize(value)
      .replaceAll(RegExp(r'[áàãâä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòõôö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c');

  void removeItem(String id) => _commit(_currentList.removeItem(id));
  void restoreItem(ShoppingListItem item) =>
      _commit(_currentList.addItem(item));
  void toggleItem(String id) => _commit(_currentList.toggleItemChecked(id));
  void clearList() => _commit(_currentList.clearItems());
  void removeCheckedItems() => _commit(
    _currentList.copyWith(
      items: _currentList.items.where((item) => !item.checked).toList(),
    ),
  );
  List<ShoppingListItem> getItemsSorted() =>
      [..._currentList.items]..sort((a, b) {
        final byName = _alphabeticalKey(
          a.productName,
        ).compareTo(_alphabeticalKey(b.productName));
        if (byName != 0) return byName;
        return a.createdAt.compareTo(b.createdAt);
      });
}
