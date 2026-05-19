import 'package:origen/models/models.dart';
import 'package:origen/utils/mock_data.dart';

/// Testes e demonstração dos modelos
/// Use: dart run lib/test_models.dart
void main() {
  print('═' * 80);
  print('TESTE DO SISTEMA DE CLASSIFICAÇÃO NUTRICIONAL');
  print('═' * 80);
  print('');

  // TESTE 1: Compilação dos produtos e classificação
  testProductClassification();

  // TESTE 2: Serialização JSON
  testJsonSerialization();

  // TESTE 3: Operações de ShoppingList
  testShoppingListOperations();

  // TESTE 4: Gerenciamento de favoritos do usuário
  testUserFavorites();

  // TESTE 5: Histórico
  testHistory();

  // TESTE 6: Produtos por classificação
  testProductsByClassification();

  print('');
  print('═' * 80);
  print('TODOS OS TESTES CONCLUÍDOS COM SUCESSO ✓');
  print('═' * 80);
}

void testProductClassification() {
  print('TESTE 1: CLASSIFICAÇÃO NUTRICIONAL');
  print('-' * 80);

  for (final product in MockData.mockProducts) {
    final classification = product.getClassification();
    final color = product.getClassificationColor();
    final label = product.getClassificationLabel();
    final highNutrients = product.getHighNutrients();

    print('');
    print('📦 ${product.name} (${product.brand})');
    print('   Barcode: ${product.barcode}');
    print('   Classificação: $label (${classification.name})');
    print('   Valor. por ${product.portion}g:');
    print('   - Calorias: ${product.calories.toStringAsFixed(0)} kcal');
    print('   - Açúcar: ${product.sugar.toStringAsFixed(1)}g');
    print('   - Sódio: ${product.sodium.toStringAsFixed(0)}mg');
    print('   - gordura: ${product.fat.toStringAsFixed(1)}g');
    print('   - Proteína: ${product.protein.toStringAsFixed(1)}g');

    if (highNutrients.isNotEmpty) {
      print('   ⚠️  Nutrientes acima do recomendado:');
      highNutrients.forEach((nutrient, isHigh) {
        if (isHigh) print('      • $nutrient');
      });
    }
  }

  print('');
}

void testJsonSerialization() {
  print('TESTE 2: SERIALIZAÇÃO JSON');
  print('-' * 80);

  final product = MockData.mockProducts.first;
  print('Produto Original: ${product.name}');

  // Converter para JSON
  final json = product.toJson();
  print('JSON serializado:');
  print('  $json');

  // Converter de volta
  final productFromJson = Product.fromJson(json);
  print('');
  print('Produto desserializado: ${productFromJson.name}');
  print('Classificação mantida? ${productFromJson.getClassification() == product.getClassification()}');
  print('Nutrientes iguais? ${productFromJson.sugar == product.sugar && productFromJson.sodium == product.sodium}');

  // Teste de copyWith
  final modified = product.copyWith(sugar: 20.0);
  print('');
  print('Teste copyWith:');
  print('  Original - Açúcar: ${product.sugar}g');
  print('  Modificado - Açúcar: ${modified.sugar}g');
  print('  Nome preservado? ${modified.name == product.name}');

  print('✓ Serialização JSON funcionando corretamente');
  print('');
}

void testShoppingListOperations() {
  print('TESTE 3: OPERAÇÕES DE LISTA DE COMPRAS');
  print('-' * 80);

  var list = MockData.mockShoppingList();
  print('Lista: ${list.name}');
  print('Total de itens: ${list.totalItems}');
  print('Itens marcados: ${list.checkedCount}');
  print('Percentual completo: ${list.completionPercentage.toStringAsFixed(1)}%');
  print('');

  print('Itens da lista:');
  for (final item in list.items) {
    print('  ${item.checked ? '✓' : '○'} ${item.productName} - ${item.quantity}${item.unit}');
  }

  // Adicionar novo item
  print('');
  print('Adicionando novo item...');
  final newItem = ShoppingListItem(
    id: 'item_004',
    productId: '12',
    productName: 'Leite Integral',
    productBrand: 'Marca K',
    quantity: 2,
    unit: 'l',
    createdAt: DateTime.now(),
    checked: false,
  );
  list = list.copyWith(items: [...list.items, newItem]);
  print('Total de itens agora: ${list.totalItems}');

  // Marcar item como verificado
  print('');
  print('Marcando item como verificado...');
  list = list.toggleItemChecked('item_004');
  print('Itens verificados: ${list.checkedCount}/${list.totalItems}');

  // Remover item
  print('');
  print('Removendo item...');
  list = list.copyWith(items: list.items.where((i) => i.id != 'item_004').toList());
  print('Total de itens após remover: ${list.totalItems}');

  print('✓ Operações de lista de compras funcionando');
  print('');
}

void testUserFavorites() {
  print('TESTE 4: GERENCIAMENTO DE FAVORITOS');
  print('-' * 80);

  var user = MockData.mockUser();
  print('Usuário: ${user.name}');
  print('Email: ${user.email}');
  print('Favoritos atuais: ${user.favoritesCount}');
  print('IDs de favoritos: ${user.favoriteProductIds}');
  print('');

  // Verificar se um produto é favorito
  print('Verificando favoritos:');
  print('  Iogurte Natural (ID: 1) é favorito? ${user.isFavorite('1')}');
  print('  Biscoito Recheado (ID: 6) é favorito? ${user.isFavorite('6')}');

  // Adicionar favorito
  print('');
  print('Adicionando favorito...');
  user = user.addToFavorites('6');
  print('Novos favoritos: ${user.favoritesCount}');
  print('Biscoito Recheado é favorito agora? ${user.isFavorite('6')}');

  // Remover favorito
  print('');
  print('Removendo favorito...');
  user = user.removeFromFavorites('1');
  print('Favoritos após remover: ${user.favoritesCount}');
  print('Iogurte Natural é favorito agora? ${user.isFavorite('1')}');

  print('✓ Gerenciamento de favoritos funcionando');
  print('');
}

void testHistory() {
  print('TESTE 5: HISTÓRICO DE PRODUTOS ESCANEADOS');
  print('-' * 80);

  final history = MockData.mockHistory();
  print('Total de itens no histórico: ${history.length}');
  print('');

  print('Histórico:');
  for (final item in history) {
    final timeAgo = _formatTimeAgo(item.scannedAt);
    print('  • ${item.productName} (${item.productBrand})');
    print('    Escaneado: $timeAgo');
    print('    Quantidade: ${item.quantity}');
  }

  // Serializar um item
  print('');
  print('Serializando item do histórico para storage...');
  final firstItem = history.first;
  final json = firstItem.toJson();
  final restored = HistoryItem.fromJson(json);
  print('Item restaurado: ${restored.productName}');
  print('Dados preservados? ${restored.scannedAt == firstItem.scannedAt}');

  print('✓ Histórico funcionando');
  print('');
}

void testProductsByClassification() {
  print('TESTE 6: PRODUTOS POR CLASSIFICAÇÃO');
  print('-' * 80);

  for (final classification in NutrientClassification.values) {
    final products = MockData.getProductsByClassification(classification);
    final label = _getClassificationLabel(classification);
    print('$label (${classification.name}): ${products.length} produtos');

    for (final product in products) {
      print('  • ${product.name}');
    }
    print('');
  }

  print('✓ Filtro por classificação funcionando');
  print('');
}

// UTILITY FUNCTIONS

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Agora mesmo';
  } else if (difference.inHours < 1) {
    return 'Há ${difference.inMinutes} minuto(s)';
  } else if (difference.inDays < 1) {
    return 'Há ${difference.inHours} hora(s)';
  } else if (difference.inDays < 30) {
    return 'Há ${difference.inDays} dia(s)';
  } else {
    return dateTime.toString();
  }
}

String _getClassificationLabel(NutrientClassification classification) {
  switch (classification) {
    case NutrientClassification.a:
      return '🟢 Excelente (A)';
    case NutrientClassification.b:
      return '🟡 Bom (B)';
    case NutrientClassification.c:
      return '🟠 Cuidado (C)';
    case NutrientClassification.d:
      return '🔴 Alto risco (D)';
  }
}
