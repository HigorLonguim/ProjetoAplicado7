import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

sealed class ProductLookupException implements Exception {
  const ProductLookupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductNotFoundException extends ProductLookupException {
  const ProductNotFoundException() : super('Produto não encontrado na base de dados. Confira o código e tente novamente.');
}

class ProductConnectionException extends ProductLookupException {
  const ProductConnectionException() : super('Não foi possível consultar agora. Verifique sua conexão e tente novamente.');
}

class ProductService {
  const ProductService({http.Client? client}) : _client = client;
  final http.Client? _client;

  Future<ProductModel> findByBarcode(String rawBarcode) async {
    final barcode = rawBarcode.replaceAll(RegExp(r'\D'), '');
    if (barcode.length < 8) throw const ProductNotFoundException();
    final client = _client ?? http.Client();
    try {
      final uri = Uri.https('world.openfoodfacts.org', '/api/v2/product/$barcode.json', {
        'fields': 'code,product_name,product_name_pt,brands,image_front_url,image_url,nutriments,nutriscore_grade,nutrient_levels,ecoscore_grade,nova_group',
      });
      final response = await client.get(uri, headers: const {
        'User-Agent': 'Origem/1.0 (projeto acadêmico)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw const ProductConnectionException();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 1) throw const ProductNotFoundException();
      return ProductModel.fromOpenFoodFacts(barcode, data);
    } on ProductLookupException {
      rethrow;
    } on SocketException {
      throw const ProductConnectionException();
    } on FormatException {
      throw const ProductConnectionException();
    } catch (_) {
      throw const ProductConnectionException();
    } finally {
      if (_client == null) client.close();
    }
  }
}
