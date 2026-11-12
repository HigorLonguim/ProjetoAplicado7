import 'dart:convert';
import '../models/history_item.dart';
import '../models/product_model.dart';
import 'local_store.dart';

class HistoryService {
  static const _key = 'scan_history_v1';
  final _store = LocalStore();

  Future<List<HistoryItem>> getItems() async {
    final raw = await _store.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => HistoryItem.fromJson(Map<String, dynamic>.from(item as Map))).toList()
        ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> add(ProductModel product) async {
    final items = await getItems();
    items.removeWhere((item) => item.productId == product.barcode);
    items.insert(0, HistoryItem(
      id: '${product.barcode}-${DateTime.now().millisecondsSinceEpoch}',
      productId: product.barcode,
      productName: product.name,
      productBrand: product.brand,
      productImage: product.imageUrl,
      scannedAt: DateTime.now(),
    ));
    await _store.setString(_key, jsonEncode(items.take(50).map((item) => item.toJson()).toList()));
  }

  Future<void> clear() async => _store.remove(_key);
}
