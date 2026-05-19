/// Representa um item no histórico de produtos escaneados
class HistoryItem {
  final String id;
  final String productId;
  final String productName;
  final String productBrand;
  final String? productImage;
  final DateTime scannedAt;
  final int quantity; // quantidade de vezes escaneado

  HistoryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productBrand,
    this.productImage,
    required this.scannedAt,
    this.quantity = 1,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productBrand': productBrand,
      'productImage': productImage,
      'scannedAt': scannedAt.toIso8601String(),
      'quantity': quantity,
    };
  }

  /// Cria HistoryItem a partir de JSON
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productBrand: json['productBrand'] as String,
      productImage: json['productImage'] as String?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  /// Cria uma cópia com valores alterados
  HistoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productBrand,
    String? productImage,
    DateTime? scannedAt,
    int? quantity,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      productImage: productImage ?? this.productImage,
      scannedAt: scannedAt ?? this.scannedAt,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() =>
      'HistoryItem(product: $productName, scannedAt: $scannedAt, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
