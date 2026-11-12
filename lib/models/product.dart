import 'package:flutter/material.dart';

/// Classificação nutricional de um produto (A-F)
/// Baseado em algoritmo de score de nutrientes críticos
enum NutrientClassification {
  a('A', 'Excelente', Color(0xFF2E7D32)),      // Verde escuro
  b('B', 'Muito Bom', Color(0xFF558B2F)),      // Verde claro
  c('C', 'Bom', Color(0xFFF57F17)),            // Amarelo escuro
  d('D', 'Regular', Color(0xFFF9A825)),        // Laranja claro
  e('E', 'Pobre', Color(0xFFF57C00)),          // Laranja escuro
  f('F', 'Muito Pobre', Color(0xFFD32F2F));    // Vermelho escuro

  final String label;
  final String description;
  final Color color;

  const NutrientClassification(this.label, this.description, this.color);
}

/// Modelo de dados para um produto alimentício
class Product {
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final double calories; // kcal por 100g
  final double sugar; // gramas (por 100g)
  final double sodium; // gramas (por 100g)
  final double fat; // gramas (por 100g)
  final double protein; // gramas (por 100g)
  final double carbohydrates; // gramas (por 100g)
  final double fiber; // gramas (por 100g)
  final double saturatedFat; // gramas (por 100g)
  final double caffeine; // mg (por 100g)
  final double portion; // gramas de porção padrão
  final DateTime? createdAt;
  // Classificações fornecidas pela API Open Food Facts
  final String? nutriscoreGrade; // 'a', 'b', 'c', 'd', 'e' (null = não disponível)
  final Map<String, String>? nutrientLevels; // ex: {'salt': 'low', 'sugars': 'high'}
  final String? ecoScore; // 'a', 'b', 'c', 'd', 'e'
  final int? novaGroup; // 1-4 (processamento alimentar)
  final bool hasNutriscoreFromApi; // indica se nutriscore veio da API

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.calories,
    required this.sugar,
    required this.sodium,
    required this.fat,
    required this.protein,
    this.carbohydrates = 0.0,
    this.fiber = 0.0,
    this.saturatedFat = 0.0,
    this.caffeine = 0.0,
    required this.portion,
    this.createdAt,
    this.nutriscoreGrade,
    this.nutrientLevels,
    this.ecoScore,
    this.novaGroup,
  }) : hasNutriscoreFromApi = nutriscoreGrade != null;

  /// Calcula a classificação nutricional (A-F)
  /// Preferência: usar Nutri-Score da API quando disponível
  /// Fallback: algoritmo local baseado em nutrientes críticos
  /// Score local: 0-10 (A), 11-25 (B), 26-40 (C), 41-60 (D), 61-85 (E), 86+ (F)
  NutrientClassification getClassification() {
    // Se Nutri-Score veio da API, usar diretamente
    if (nutriscoreGrade != null) {
      return _nutriscoreToClassification(nutriscoreGrade!);
    }
    
    // Fallback: algoritmo local baseado em score de nutrientes
    double score = 0;

    // AÇÚCAR (0-30 pontos) - crítico para saúde bucal e metabólica
    if (sugar > 15) {
      score += 30; // Muito alto
    } else if (sugar > 12) {
      score += 25; // Alto
    } else if (sugar > 8) {
      score += 20; // Moderado-Alto
    } else if (sugar > 5) {
      score += 10; // Moderado
    } else if (sugar > 2) {
      score += 5; // Baixo
    }

    // SÓDIO (0-30 pontos) - importante para hipertensão
    // Valores em gramas por 100g (ex: 0.8g == 800mg)
    if (sodium > 0.8) {
      score += 30; // Muito alto (>=800mg/100g)
    } else if (sodium > 0.6) {
      score += 25; // Alto (>=600mg/100g)
    } else if (sodium > 0.4) {
      score += 20; // Moderado-Alto (>=400mg/100g)
    } else if (sodium > 0.2) {
      score += 10; // Moderado (>=200mg/100g)
    } else if (sodium > 0.1) {
      score += 5; // Baixo (>=100mg/100g)
    }

    // GORDURA SATURADA (0-25 pontos)
    if (saturatedFat > 5) {
      score += 25; // Muito alto
    } else if (saturatedFat > 3.5) {
      score += 20; // Alto
    } else if (saturatedFat > 2) {
      score += 15; // Moderado-Alto
    } else if (saturatedFat > 1) {
      score += 10; // Moderado
    } else if (saturatedFat > 0.5) {
      score += 5; // Baixo
    }

    // CALORIAS (0-15 pontos)
    if (calories > 400) {
      score += 15; // Muito calórico
    } else if (calories > 300) {
      score += 12; // Calórico
    } else if (calories > 200) {
      score += 8; // Moderado
    } else if (calories > 100) {
      score += 4; // Baixo
    }

    // Classificação final (escala A-F)
    if (score > 85) {
      return NutrientClassification.f; // F: Muito Pobre (vermelho)
    } else if (score > 60) {
      return NutrientClassification.e; // E: Pobre (laranja escuro)
    } else if (score > 40) {
      return NutrientClassification.d; // D: Regular (laranja claro)
    } else if (score > 25) {
      return NutrientClassification.c; // C: Bom (amarelo escuro)
    } else if (score > 10) {
      return NutrientClassification.b; // B: Muito Bom (verde claro)
    } else {
      return NutrientClassification.a; // A: Excelente (verde escuro)
    }
  }
  
  /// Converte grade Nutri-Score (a-e) para classificação local (A-F)
  static NutrientClassification _nutriscoreToClassification(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return NutrientClassification.a;
      case 'b':
        return NutrientClassification.b;
      case 'c':
        return NutrientClassification.c;
      case 'd':
        return NutrientClassification.d;
      case 'e':
        return NutrientClassification.e;
      default:
        return NutrientClassification.f; // fallback para E se inválido
    }
  }

  /// Retorna a cor visual para a classificação
  Color getClassificationColor() {
    return getClassification().color;
  }

  /// Retorna o label legível da classificação (ex: "A")
  String getClassificationLabel() {
    return getClassification().label;
  }

  /// Retorna a descrição da classificação (ex: "Excelente")
  String getClassificationDescription() {
    return getClassification().description;
  }

  /// Define quais nutrientes estão em nível ALTO/CRÍTICO
  /// Preferência: usar nutrient_levels da API quando disponível
  /// Fallback: thresholds locais
  Map<String, bool> getHighNutrients() {
    // Se temos nutrient_levels da API, usar esses dados
    if (nutrientLevels != null && nutrientLevels!.isNotEmpty) {
      return {
        'sugar': nutrientLevels!['sugars']?.toLowerCase() == 'high',
        'sodium': nutrientLevels!['salt']?.toLowerCase() == 'high',
        'fat': nutrientLevels!['fat']?.toLowerCase() == 'high',
        'saturated-fat': nutrientLevels!['saturated-fat']?.toLowerCase() == 'high',
      };
    }
    
    // Fallback: thresholds locais (valores por 100g)
    return {
      'sugar': sugar > 10,
      'sodium': sodium > 0.5, // 0.5g == 500mg
      'fat': fat > 5,
      'saturated-fat': saturatedFat > 1.5,
    };
  }

  /// Converte para JSON (para persistência)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'calories': calories,
      'sugar': sugar,
      'sodium': sodium,
      'fat': fat,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'saturatedFat': saturatedFat,
      'caffeine': caffeine,
      'portion': portion,
      'createdAt': createdAt?.toIso8601String(),
      'nutriscoreGrade': nutriscoreGrade,
      'nutrientLevels': nutrientLevels,
      'ecoScore': ecoScore,
      'novaGroup': novaGroup,
    };
  }

  /// Cria Product a partir de JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      calories: (json['calories'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      saturatedFat: (json['saturatedFat'] as num?)?.toDouble() ?? 0.0,
      caffeine: (json['caffeine'] as num?)?.toDouble() ?? 0.0,
      portion: (json['portion'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      nutriscoreGrade: json['nutriscoreGrade'] as String?,
      nutrientLevels: json['nutrientLevels'] != null
          ? Map<String, String>.from(json['nutrientLevels'])
          : null,
      ecoScore: json['ecoScore'] as String?,
      novaGroup: json['novaGroup'] as int?,
    );
  }

  /// Cria uma cópia com valores alterados
  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? imageUrl,
    double? calories,
    double? sugar,
    double? sodium,
    double? fat,
    double? protein,
    double? carbohydrates,
    double? fiber,
    double? saturatedFat,
    double? caffeine,
    double? portion,
    DateTime? createdAt,
    String? nutriscoreGrade,
    Map<String, String>? nutrientLevels,
    String? ecoScore,
    int? novaGroup,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fiber: fiber ?? this.fiber,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      caffeine: caffeine ?? this.caffeine,
      portion: portion ?? this.portion,
      createdAt: createdAt ?? this.createdAt,
      nutriscoreGrade: nutriscoreGrade ?? this.nutriscoreGrade,
      nutrientLevels: nutrientLevels ?? this.nutrientLevels,
      ecoScore: ecoScore ?? this.ecoScore,
      novaGroup: novaGroup ?? this.novaGroup,
    );
  }

  @override
  String toString() {
    return 'Product(name: $name, brand: $brand, classification: ${getClassification().label})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          barcode == other.barcode;

  @override
  int get hashCode => id.hashCode ^ barcode.hashCode;
}
