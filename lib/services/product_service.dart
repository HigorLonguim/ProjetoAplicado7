import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

sealed class ProductLookupException implements Exception {
  const ProductLookupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductNotFoundException extends ProductLookupException {
  const ProductNotFoundException()
    : super(
        'Produto não encontrado na base de dados. Confira o código e tente novamente.',
      );
}

class ProductConnectionException extends ProductLookupException {
  const ProductConnectionException()
    : super(
        'Não foi possível consultar agora. Verifique sua conexão e tente novamente.',
      );
}

class ProductOfflineException extends ProductLookupException {
  const ProductOfflineException()
    : super('Você está sem conexão. Conecte-se à internet e tente novamente.');
}

class ProductService {
  const ProductService({
    http.Client? client,
    List<String> hosts = _defaultHosts,
  }) : _client = client,
       _hosts = hosts;

  static const _defaultHosts = <String>[
    'world.openfoodfacts.org',
    'api.openfoodfacts.org',
  ];

  final http.Client? _client;
  final List<String> _hosts;

  Future<ProductModel> findByBarcode(String rawBarcode) async {
    final barcode = rawBarcode.replaceAll(RegExp(r'\D'), '');
    if (barcode.length < 8) throw const ProductNotFoundException();
    final client = _client ?? http.Client();
    try {
      for (final host in _hosts) {
        try {
          final response = await client
              .get(_productUri(host, barcode), headers: _headers())
              .timeout(const Duration(seconds: 8));
          final product = _readResponse(barcode, response);
          if (product != null) return product;
        } on ProductNotFoundException {
          rethrow;
        } on TimeoutException {
          continue;
        } on http.ClientException {
          continue;
        } on FormatException {
          continue;
        }
      }
      throw const ProductConnectionException();
    } finally {
      if (_client == null) client.close();
    }
  }

  Uri _productUri(String host, String barcode) => Uri.https(
    host,
    '/api/v2/product/$barcode.json',
    {
      'fields':
          'code,product_name,product_name_pt,brands,image_front_url,image_url,nutriments,nutriscore_grade,nutrient_levels,ecoscore_grade,nova_group',
    },
  );

  Map<String, String> _headers() => {
    'Accept': 'application/json',
    if (!kIsWeb) 'User-Agent': 'Origem/1.0 (projeto acadêmico)',
  };

  ProductModel? _readResponse(String barcode, http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 404) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const FormatException();
    final data = Map<String, dynamic>.from(decoded);
    if (data['status'] != 1) throw const ProductNotFoundException();
    if (response.statusCode != 200) return null;
    return ProductModel.fromOpenFoodFacts(barcode, data);
  }
}
