import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:origem/services/product_service.dart';

const _barcode = '7891962079585';
const _productResponse = '''
{
  "code": "7891962079585",
  "status": 1,
  "product": {
    "product_name_pt": "Biscoito Chico",
    "brands": "Bauducco",
    "nutriments": {
      "energy-kcal_100g": 492,
      "sugars_100g": 36
    }
  }
}
''';

void main() {
  test('retorna o produto consultado pelo código normalizado', () async {
    final service = ProductService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v2/product/$_barcode.json');
        expect(request.headers['Accept'], 'application/json');
        return http.Response(_productResponse, 200);
      }),
    );

    final product = await service.findByBarcode('789 1962 07958 5');

    expect(product.barcode, _barcode);
    expect(product.name, 'Biscoito Chico');
    expect(product.brand, 'Bauducco');
    expect(product.calories, 492);
  });

  test('tenta o domínio reserva quando a primeira consulta falha', () async {
    final visitedHosts = <String>[];
    final service = ProductService(
      hosts: const ['principal.exemplo', 'reserva.exemplo'],
      client: MockClient((request) async {
        visitedHosts.add(request.url.host);
        if (request.url.host == 'principal.exemplo') {
          return http.Response('Serviço indisponível', 503);
        }
        return http.Response(_productResponse, 200);
      }),
    );

    final product = await service.findByBarcode(_barcode);

    expect(product.name, 'Biscoito Chico');
    expect(visitedHosts, ['principal.exemplo', 'reserva.exemplo']);
  });

  test('mantém produto não encontrado como resposta definitiva', () async {
    var requests = 0;
    final service = ProductService(
      hosts: const ['principal.exemplo', 'reserva.exemplo'],
      client: MockClient((request) async {
        requests++;
        return http.Response('{"status":0}', 404);
      }),
    );

    await expectLater(
      service.findByBarcode(_barcode),
      throwsA(isA<ProductNotFoundException>()),
    );
    expect(requests, 1);
  });

  test('informa falha de conexão após esgotar as rotas', () async {
    final service = ProductService(
      hosts: const ['principal.exemplo', 'reserva.exemplo'],
      client: MockClient((request) async {
        throw http.ClientException('Falha de rede', request.url);
      }),
    );

    await expectLater(
      service.findByBarcode(_barcode),
      throwsA(isA<ProductConnectionException>()),
    );
  });
}
