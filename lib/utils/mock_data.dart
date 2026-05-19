import 'package:origen/models/models.dart';

/// Dados mock para demonstração e testes
/// Produtos reais ou similares vendidos no Brasil
class MockData {
  /// Produtos de exemplo com dados nutricionais reais (aproximados)
  static final List<Product> mockProducts = [
    // PRODUTOS SAUDÁVEIS (Classificação A/B)
    Product(
      id: '1',
      barcode: '7898000000001',
      name: 'Iogurte Natural',
      brand: 'Marca A',
      calories: 70,
      sugar: 3.5,
      sodium: 50,
      fat: 0.5,
      protein: 5.5,
      portion: 100,
      imageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Product(
      id: '2',
      barcode: '7898000000002',
      name: 'Pão Integral',
      brand: 'Marca B',
      calories: 220,
      sugar: 2.5,
      sodium: 350,
      fat: 2.5,
      protein: 8.0,
      portion: 50,
      imageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Product(
      id: '3',
      barcode: '7898000000003',
      name: 'Maçã Verde',
      brand: 'Frutaria X',
      calories: 52,
      sugar: 10.0,
      sodium: 2,
      fat: 0.2,
      protein: 0.3,
      portion: 100,
      imageUrl: null,
    ),
    // PRODUTOS MODERADOS (Classificação B/C)
    Product(
      id: '4',
      barcode: '7898000000004',
      name: 'Suco de Laranja NFC',
      brand: 'Marca C',
      calories: 45,
      sugar: 8.5,
      sodium: 35,
      fat: 0.2,
      protein: 0.8,
      portion: 200,
      imageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Product(
      id: '5',
      barcode: '7898000000005',
      name: 'Arroz Integral',
      brand: 'Marca D',
      calories: 130,
      sugar: 0.5,
      sodium: 5,
      fat: 1.0,
      protein: 2.5,
      portion: 100,
      imageUrl: null,
    ),
    // PRODUTOS COM CUIDADO (Classificação C/D)
    Product(
      id: '6',
      barcode: '7898000000006',
      name: 'Biscoito Recheado',
      brand: 'Marca E',
      calories: 150,
      sugar: 12.0,
      sodium: 250,
      fat: 6.0,
      protein: 1.5,
      portion: 30,
      imageUrl: null,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '7',
      barcode: '7898000000007',
      name: 'Refrigerante Cola',
      brand: 'Marca F',
      calories: 42,
      sugar: 10.6,
      sodium: 25,
      fat: 0.0,
      protein: 0.0,
      portion: 250,
      imageUrl: null,
    ),
    Product(
      id: '8',
      barcode: '7898000000008',
      name: 'Macarrão Instantâneo',
      brand: 'Marca G',
      calories: 380,
      sugar: 1.5,
      sodium: 1200,
      fat: 15.0,
      protein: 13.0,
      portion: 85,
      imageUrl: null,
    ),
    // PRODUTOS POUCO SAUDÁVEIS (Classificação D)
    Product(
      id: '9',
      barcode: '7898000000009',
      name: 'Chocolate ao Leite',
      brand: 'Marca H',
      calories: 540,
      sugar: 50.0,
      sodium: 100,
      fat: 32.0,
      protein: 8.0,
      portion: 100,
      imageUrl: null,
    ),
    Product(
      id: '10',
      barcode: '7898000000010',
      name: 'Salgadinho de Queijo',
      brand: 'Marca I',
      calories: 560,
      sugar: 2.0,
      sodium: 800,
      fat: 35.0,
      protein: 10.0,
      portion: 100,
      imageUrl: null,
    ),
    // MAIS EXEMPLOS
    Product(
      id: '11',
      barcode: '7898000000011',
      name: 'Cereal Matinal',
      brand: 'Marca J',
      calories: 380,
      sugar: 18.0,
      sodium: 600,
      fat: 8.0,
      protein: 7.0,
      portion: 100,
      imageUrl: null,
    ),
    Product(
      id: '12',
      barcode: '7898000000012',
      name: 'Leite Integral',
      brand: 'Marca K',
      calories: 64,
      sugar: 4.8,
      sodium: 50,
      fat: 3.6,
      protein: 3.2,
      portion: 100,
      imageUrl: null,
    ),
    Product(
      id: '13',
      barcode: '7898000000013',
      name: 'Azeite de Oliva',
      brand: 'Marca L',
      calories: 884,
      sugar: 0.0,
      sodium: 2,
      fat: 98.0,
      protein: 0.0,
      portion: 100,
      imageUrl: null,
    ),
    Product(
      id: '14',
      barcode: '7898000000014',
      name: 'Banana',
      brand: 'Frutaria Y',
      calories: 89,
      sugar: 12.2,
      sodium: 1,
      fat: 0.3,
      protein: 1.1,
      portion: 100,
      imageUrl: null,
    ),
    Product(
      id: '15',
      barcode: '7898000000015',
      name: 'Pizza Congelada',
      brand: 'Marca M',
      calories: 280,
      sugar: 4.0,
      sodium: 700,
      fat: 12.0,
      protein: 12.0,
      portion: 100,
      imageUrl: null,
    ),
  ];

  /// Encontra um produto pelo barcode
  static Product? findProductByBarcode(String barcode) {
    try {
      return mockProducts.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  /// Busca produtos pelo nome
  static List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return mockProducts
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.brand.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Retorna produtos pela classificação
  static List<Product> getProductsByClassification(
      NutrientClassification classification) {
    return mockProducts
        .where((p) => p.getClassification() == classification)
        .toList();
  }

  /// Exemplo de usuário mock
  static User mockUser() {
    return User(
      id: 'user_001',
      email: 'usuario@exemplo.com',
      name: 'João Silva',
      createdAt: DateTime.now(),
      favoriteProductIds: ['1', '3', '5'],
      shoppingListIds: ['list_001'],
    );
  }

  /// Exemplo de lista de compras mock
  static ShoppingList mockShoppingList() {
    return ShoppingList(
      id: 'list_001',
      name: 'Compras do Mês',
      createdAt: DateTime.now(),
      items: [
        ShoppingListItem(
          id: 'item_001',
          productId: '1',
          productName: 'Iogurte Natural',
          productBrand: 'Marca A',
          quantity: 4,
          unit: 'un',
          createdAt: DateTime.now(),
          checked: false,
        ),
        ShoppingListItem(
          id: 'item_002',
          productId: '2',
          productName: 'Pão Integral',
          productBrand: 'Marca B',
          quantity: 3,
          unit: 'un',
          createdAt: DateTime.now(),
          checked: true,
        ),
        ShoppingListItem(
          id: 'item_003',
          productId: '5',
          productName: 'Arroz Integral',
          productBrand: 'Marca D',
          quantity: 2,
          unit: 'kg',
          createdAt: DateTime.now(),
          checked: false,
        ),
      ],
    );
  }

  /// Histórico exemplo
  static List<HistoryItem> mockHistory() {
    return [
      HistoryItem(
        id: 'hist_001',
        productId: '1',
        productName: 'Iogurte Natural',
        productBrand: 'Marca A',
        scannedAt: DateTime.now().subtract(const Duration(hours: 3)),
        quantity: 2,
      ),
      HistoryItem(
        id: 'hist_002',
        productId: '6',
        productName: 'Biscoito Recheado',
        productBrand: 'Marca E',
        scannedAt: DateTime.now().subtract(const Duration(days: 1)),
        quantity: 1,
      ),
      HistoryItem(
        id: 'hist_003',
        productId: '7',
        productName: 'Refrigerante Cola',
        productBrand: 'Marca F',
        scannedAt: DateTime.now().subtract(const Duration(days: 2)),
        quantity: 1,
      ),
    ];
  }
}
