/// Representa um item em uma lista de compras
class ShoppingListItem {
  final String id;
  final String productId;
  final String productName;
  final String productBrand;
  final String? productImage;
  final double quantity;
  final String unit; // "un", "kg", "l", etc
  final bool checked;
  final DateTime createdAt;

  ShoppingListItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productBrand,
    this.productImage,
    required this.quantity,
    required this.unit,
    this.checked = false,
    required this.createdAt,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productBrand': productBrand,
      'productImage': productImage,
      'quantity': quantity,
      'unit': unit,
      'checked': checked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Cria ShoppingListItem a partir de JSON
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productBrand: json['productBrand'] as String,
      productImage: json['productImage'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'un',
      checked: json['checked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Cria uma cópia com valores alterados
  ShoppingListItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productBrand,
    String? productImage,
    double? quantity,
    String? unit,
    bool? checked,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ShoppingListItem($productName, qty: $quantity $unit, checked: $checked)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Representa uma lista de compras
class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingListItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? marketId; // ID do mercado associado (geolocalização)
  final bool archived;

  ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
    required this.createdAt,
    this.updatedAt,
    this.marketId,
    this.archived = false,
  });

  /// Adiciona um item à lista
  ShoppingList addItem(ShoppingListItem item) {
    final newItems = [...items, item];
    return copyWith(items: newItems);
  }

  /// Remove um item da lista
  ShoppingList removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: newItems);
  }

  /// Atualiza um item existente
  ShoppingList updateItem(ShoppingListItem updatedItem) {
    final newItems = items.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
    return copyWith(items: newItems);
  }

  /// Marca/desmarca um item como comprado
  ShoppingList toggleItemChecked(String itemId) {
    final newItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(checked: !item.checked);
      }
      return item;
    }).toList();
    return copyWith(items: newItems);
  }

  /// Limpa todos os itens da lista
  ShoppingList clearItems() {
    return copyWith(items: []);
  }

  /// Retorna apenas itens não comprados
  List<ShoppingListItem> getPendingItems() {
    return items.where((item) => !item.checked).toList();
  }

  /// Retorna apenas itens já comprados
  List<ShoppingListItem> getCheckedItems() {
    return items.where((item) => item.checked).toList();
  }

  /// Total de itens
  int get totalItems => items.length;

  /// Total de itens comprados
  int get checkedCount => getCheckedItems().length;

  /// Percentual de conclusão
  double get completionPercentage =>
      totalItems == 0 ? 0 : (checkedCount / totalItems) * 100;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'marketId': marketId,
      'archived': archived,
    };
  }

  /// Cria ShoppingList a partir de JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: itemsList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      marketId: json['marketId'] as String?,
      archived: json['archived'] as bool? ?? false,
    );
  }

  /// Cria uma cópia com valores alterados
  ShoppingList copyWith({
    String? id,
    String? name,
    List<ShoppingListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? marketId,
    bool? archived,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      marketId: marketId ?? this.marketId,
      archived: archived ?? this.archived,
    );
  }

  @override
  String toString() =>
      'ShoppingList(name: $name, items: $totalItems, checked: $checkedCount, completion: ${completionPercentage.toStringAsFixed(1)}%)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
