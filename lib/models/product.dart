import 'package:flutter/material.dart';

/// Classificação nutricional de um produto (A/B/C/D)
enum NutrientClassification {
  a('A', 'Bom'),
  b('B', 'Adequado'),
  c('C', 'Com cuidado'),
  d('D', 'Alto'),
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

  /// Calcula a classificação geral do produto (A/B/C/D)
  /// baseado em um score dos nutrientes críticos
  NutrientClassification getClassification() {
    double score = 0;

    // Açúcar: crítico para saúde bucal e metabólica
    if (sugar > 12) {
      score += 30; // Muito alto
    } else if (sugar > 8) {
      score += 20; // Alto
    } else if (sugar > 4) {
      score += 10; // Moderado
    }

    // Sódio: importante para HAS
    if (sodium > 600) {
      score += 30; // Muito alto
    } else if (sodium > 400) {
      score += 20; // Alto
    } else if (sodium > 200) {
      score += 10; // Moderado
    }

    // Gordura saturada (estimada como 30% da gordura total para MVP)
    final saturatedFat = fat * 0.3;
    if (saturatedFat > 4) {
      score += 25; // Muito alto
    } else if (saturatedFat > 2) {
      score += 15; // Alto
    } else if (saturatedFat > 1) {
      score += 8; // Moderado
    }

    // Calorias (relativo à porção)
    if (calories > 300) {
      score += 10; // Calórico
    }

    // Classificação final
    if (score >= 60) {
      return NutrientClassification.d; // D: Alto (vermelho)
    } else if (score >= 40) {
      return NutrientClassification.c; // C: Com cuidado (laranja)
    } else if (score >= 20) {
      return NutrientClassification.b; // B: Adequado (amarelo)
    } else {
      return NutrientClassification.a; // A: Bom (verde)
    }
  }

  /// Retorna a cor visual para a classificação
  Color getClassificationColor() {
    final classification = getClassification();
    switch (classification) {
      case NutrientClassification.a:
        return const Color(0xFF4CAF50); // Verde
      case NutrientClassification.b:
        return const Color(0xFFFBC02D); // Amarelo
      case NutrientClassification.c:
        return const Color(0xFFFFA726); // Laranja
      case NutrientClassification.d:
        return const Color(0xFFEF5350); // Vermelho
    }
  }

  /// Retorna o label legível da classificação
  String getClassificationLabel() {
    return getClassification().label;
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
