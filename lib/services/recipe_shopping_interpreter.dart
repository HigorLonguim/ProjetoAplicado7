import '../models/recommendation.dart';

class RecipeShoppingItem {
  const RecipeShoppingItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.original,
  });

  final String name;
  final double quantity;
  final String unit;
  final String original;

  String get readableQuantity {
    final value = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
              .replaceAll('.', ',');
    return '$value $unit';
  }
}

class RecipeShoppingPlan {
  const RecipeShoppingPlan({
    required this.atHome,
    required this.toBuy,
    required this.ignoredStaples,
  });

  final List<RecipeShoppingItem> atHome;
  final List<RecipeShoppingItem> toBuy;
  final List<String> ignoredStaples;
}

class RecipeShoppingInterpreter {
  const RecipeShoppingInterpreter._();

  static RecipeShoppingPlan build({
    required MealRecommendation recipe,
    required int servings,
    required Set<String> pantry,
  }) {
    final atHome = <RecipeShoppingItem>[];
    final toBuy = <RecipeShoppingItem>[];
    final ignored = <String>[];

    for (final ingredient in recipe.ingredientsForServings(servings)) {
      if (_isStaple(ingredient)) {
        ignored.add(ingredient);
        continue;
      }
      final parsed = _parse(ingredient);
      if (parsed == null) continue;
      if (_matchesPantry(parsed, pantry)) {
        atHome.add(parsed);
      } else {
        toBuy.add(parsed);
      }
    }

    return RecipeShoppingPlan(
      atHome: _merge(atHome),
      toBuy: _merge(toBuy),
      ignoredStaples: List.unmodifiable(ignored),
    );
  }

  static List<RecipeShoppingItem> merge(
    Iterable<RecipeShoppingItem> ingredients,
  ) => _merge(ingredients);

  static RecipeShoppingItem? _parse(String ingredient) {
    final leading = _leadingQuantity(ingredient);
    if (leading == null) return null;
    var quantity = leading.value;
    var remainder = ingredient.substring(leading.end).trim();
    remainder = remainder.replaceFirst(
      RegExp(r'^de\s+', caseSensitive: false),
      '',
    );

    var unit = 'un';
    final measures = <({RegExp pattern, String unit})>[
      (pattern: RegExp(r'^kg\s+(?:de\s+)?', caseSensitive: false), unit: 'kg'),
      (pattern: RegExp(r'^g\s+(?:de\s+)?', caseSensitive: false), unit: 'g'),
      (pattern: RegExp(r'^ml\s+(?:de\s+)?', caseSensitive: false), unit: 'ml'),
      (
        pattern: RegExp(r'^litros?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'l',
      ),
      (
        pattern: RegExp(r'^xícaras?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'xíc.',
      ),
      (
        pattern: RegExp(
          r'^colheres?\s+de\s+sopa\s+(?:de\s+)?',
          caseSensitive: false,
        ),
        unit: 'col. sopa',
      ),
      (
        pattern: RegExp(
          r'^colheres?\s+de\s+chá\s+(?:de\s+)?',
          caseSensitive: false,
        ),
        unit: 'col. chá',
      ),
      (
        pattern: RegExp(r'^latas?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'lata',
      ),
      (
        pattern: RegExp(r'^potes?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'pote',
      ),
      (
        pattern: RegExp(r'^fatias?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'fatia',
      ),
      (
        pattern: RegExp(r'^unidades?\s+(?:de\s+)?', caseSensitive: false),
        unit: 'un',
      ),
    ];

    for (final measure in measures) {
      final match = measure.pattern.firstMatch(remainder);
      if (match == null) continue;
      unit = measure.unit;
      remainder = remainder.substring(match.end).trim();
      break;
    }

    final name = _canonicalName(remainder);
    if (name.isEmpty) return null;

    final packageUnit = _packageUnitFor(name);
    if (packageUnit != null) {
      return RecipeShoppingItem(
        name: name,
        quantity: 1,
        unit: packageUnit,
        original: ingredient,
      );
    }

    if (unit == 'kg') {
      quantity *= 1000;
      unit = 'g';
    } else if (unit == 'l') {
      quantity *= 1000;
      unit = 'ml';
    }

    if (unit == 'xíc.') {
      final conversion = _cupConversion(name);
      if (conversion != null) {
        quantity *= conversion.amount;
        unit = conversion.unit;
      }
    }

    quantity = _purchaseQuantity(quantity, unit);
    return RecipeShoppingItem(
      name: name,
      quantity: quantity,
      unit: unit,
      original: ingredient,
    );
  }

  static ({double value, int end})? _leadingQuantity(String value) {
    final mixed = RegExp(r'^(\d+)\s+e\s+(\d+)\/(\d+)').firstMatch(value);
    if (mixed != null) {
      return (
        value:
            double.parse(mixed.group(1)!) +
            double.parse(mixed.group(2)!) / double.parse(mixed.group(3)!),
        end: mixed.end,
      );
    }
    final fraction = RegExp(r'^(\d+)\/(\d+)').firstMatch(value);
    if (fraction != null) {
      return (
        value:
            double.parse(fraction.group(1)!) / double.parse(fraction.group(2)!),
        end: fraction.end,
      );
    }
    final decimal = RegExp(r'^(\d+(?:[\.,]\d+)?)').firstMatch(value);
    if (decimal == null) return null;
    return (
      value: double.parse(decimal.group(1)!.replaceAll(',', '.')),
      end: decimal.end,
    );
  }

  static ({double amount, String unit})? _cupConversion(String name) {
    final normalized = _normalize(name);
    if (normalized.contains('leite') || normalized.contains('iogurte')) {
      return (amount: 240, unit: 'ml');
    }
    const grams = <String, double>{
      'arroz': 180,
      'feijao': 170,
      'farinha': 120,
      'acucar': 200,
      'aveia': 90,
      'queijo': 100,
      'frango': 140,
      'milho': 160,
    };
    for (final entry in grams.entries) {
      if (normalized.contains(entry.key)) {
        return (amount: entry.value, unit: 'g');
      }
    }
    return null;
  }

  static double _purchaseQuantity(double value, String unit) {
    if (unit == 'g' || unit == 'ml') return _roundUp(value, 50);
    if (unit == 'un' || unit == 'lata' || unit == 'pote') {
      return value.ceilToDouble().clamp(1, double.infinity).toDouble();
    }
    if (unit == 'fatia') {
      return value.ceilToDouble().clamp(1, double.infinity).toDouble();
    }
    if (unit == 'xíc.') return _roundUp(value, .25);
    return _roundUp(value, .5);
  }

  static double _roundUp(double value, double step) =>
      ((value / step).ceil() * step).clamp(step, double.infinity).toDouble();

  static String _canonicalName(String value) {
    final normalized = _normalize(value);
    const names = <String, String>{
      'pasta de amendoim': 'Pasta de amendoim',
      'pasta de castanha': 'Pasta de castanhas',
      'molho de tomate': 'Molho de tomate',
      'requeijao': 'Requeijão',
      'mostarda': 'Mostarda',
      'tahine': 'Tahine',
      'leite de coco': 'Leite de coco',
      'frango': 'Frango',
      'sobrecoxa': 'Frango',
      'arroz': 'Arroz',
      'macarrao': 'Macarrão',
      'massa de pastel': 'Massa de pastel',
      'atum': 'Atum',
      'ovo': 'Ovos',
      'tomate': 'Tomate',
      'cebola': 'Cebola',
      'batata': 'Batata',
      'cenoura': 'Cenoura',
      'banana': 'Banana',
      'pao': 'Pão',
      'iogurte': 'Iogurte',
      'leite': 'Leite',
      'queijo': 'Queijo',
      'feijao': 'Feijão',
      'farinha': 'Farinha',
      'aveia': 'Aveia',
      'milho': 'Milho',
      'brocolis': 'Brócolis',
      'cogumelo': 'Cogumelos',
      'berinjela': 'Berinjela',
      'abobrinha': 'Abobrinha',
      'pimentao': 'Pimentão',
      'espinafre': 'Espinafre',
      'grao-de-bico': 'Grão-de-bico',
      'lentilha': 'Lentilha',
      'tilapia': 'Tilápia',
      'salmao': 'Salmão',
      'sardinha': 'Sardinha',
      'peixe': 'Peixe',
    };
    for (final entry in names.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }

    var cleaned = value
        .replaceAll(
          RegExp(
            r'\b(picad[ao]s?|fatiad[ao]s?|ralad[ao]s?|cozid[ao]s?|amadurecid[ao]s?|madur[ao]s?|amassad[ao]s?|escorrid[ao]s?|em cubos|sem sementes|hidratad[ao]s?|gelad[ao]s?)\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return '';
    cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    return cleaned;
  }

  static String? _packageUnitFor(String name) {
    final value = _normalize(name);
    if (value.contains('pasta de amendoim') ||
        value.contains('pasta de castanha') ||
        value.contains('requeijao') ||
        value.contains('tahine')) {
      return 'pote';
    }
    if (value.contains('mostarda')) return 'frasco';
    if (value.contains('molho de tomate')) return 'sachê';
    return null;
  }

  static bool _matchesPantry(RecipeShoppingItem item, Set<String> pantry) {
    final content = _normalize('${item.name} ${item.original}');
    return pantry.any((value) {
      final term = _normalize(value);
      if (term == 'ovos') return content.contains('ovo');
      if (term == 'pao') return content.contains('pao');
      if (term == 'macarrao') {
        return content.contains('macarrao') || content.contains('massa');
      }
      return content.contains(term);
    });
  }

  static bool _isStaple(String ingredient) {
    final value = _normalize(ingredient);
    if (value.contains('agua')) return true;
    const terms = [
      'agua',
      'sal ',
      'sal,',
      'sal e',
      'sal ou',
      'pimenta',
      'azeite',
      'oleo',
      'alho',
      'oregano',
      'canela',
      'cheiro-verde',
      'salsinha',
      'manjericao',
      'paprica',
      'cominho',
    ];
    if (terms.any(value.contains) && value.contains('a gosto')) return true;
    return RegExp(
      r'^(\d+(?:[\.,]\d+)?\s+)?(agua|sal|pimenta|azeite|oleo)\b',
    ).hasMatch(value);
  }

  static List<RecipeShoppingItem> _merge(
    Iterable<RecipeShoppingItem> ingredients,
  ) {
    final merged = <String, RecipeShoppingItem>{};
    for (final item in ingredients) {
      final key = '${_normalize(item.name)}|${item.unit}';
      final current = merged[key];
      merged[key] = current == null
          ? item
          : RecipeShoppingItem(
              name: current.name,
              quantity: current.quantity + item.quantity,
              unit: current.unit,
              original: '${current.original}; ${item.original}',
            );
    }
    final result = merged.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(result);
  }

  static String _normalize(String value) {
    const accents = 'áàãâäéèêëíìîïóòõôöúùûüç';
    const plain = 'aaaaaeeeeiiiiooooouuuuc';
    var result = value.toLowerCase();
    for (var index = 0; index < accents.length; index++) {
      result = result.replaceAll(accents[index], plain[index]);
    }
    return result;
  }
}
