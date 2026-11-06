import 'local_store.dart';

class FavoritesService {
  static const _key = 'favorite_barcodes_v1';
  final _store = LocalStore();
  Future<bool> contains(String barcode) async => (await _store.getStringList(_key))?.contains(barcode) ?? false;
  Future<bool> toggle(String barcode) async {
    final values = (await _store.getStringList(_key))?.toSet() ?? <String>{};
    final added = values.add(barcode);
    if (!added) values.remove(barcode);
    await _store.setStringList(_key, values.toList());
    return added;
  }
}
