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
  final double calories; // kcal por porção
  final double sugar; // gramas
  final double sodium; // miligramas
  final double fat; // gramas
  final double protein; // gramas
  final double portion; // gramas (p. ex: 30g)
  final DateTime? createdAt;

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
    required this.portion,
    this.createdAt,
  });

  /// Calcula a classificação nutricional (A-F)
  /// Baseado em algoritmo de score dos nutrientes críticos
  /// Score: 0-10 (A), 11-25 (B), 26-40 (C), 41-60 (D), 61-85 (E), 86+ (F)
  NutrientClassification getClassification() {
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
    if (sodium > 800) {
      score += 30; // Muito alto
    } else if (sodium > 600) {
      score += 25; // Alto
    } else if (sodium > 400) {
      score += 20; // Moderado-Alto
    } else if (sodium > 200) {
      score += 10; // Moderado
    } else if (sodium > 100) {
      score += 5; // Baixo
    }

    // GORDURA SATURADA (0-25 pontos)
    // Considerando gordura saturada como 30-40% da gordura total
    final saturatedFat = fat * 0.35;
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

    // CALORIAS (0-15 pontos) - relativo à porção
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

  /// Define quais nutrientes estão em nível ALTO
  Map<String, bool> getHighNutrients() {
    return {
      'sugar': sugar > 10,
      'sodium': sodium > 500,
      'fat': fat > 5,
      'calories': calories > 250,
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
      'portion': portion,
      'createdAt': createdAt?.toIso8601String(),
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
      portion: (json['portion'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
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
    double? portion,
    DateTime? createdAt,
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
      portion: portion ?? this.portion,
      createdAt: createdAt ?? this.createdAt,
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
