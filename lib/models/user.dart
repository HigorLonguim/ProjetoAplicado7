/// Modelo de usuário do app
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final List<String> favoriteProductIds; // IDs dos produtos favoritos
  final List<String> shoppingListIds; // IDs das listas criadas
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.favoriteProductIds = const [],
    this.shoppingListIds = const [],
    required this.createdAt,
    this.lastLogin,
  });

  /// Verifica se um produto está nos favoritos
  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  /// Adiciona um produto aos favoritos
  User addToFavorites(String productId) {
    if (favoriteProductIds.contains(productId)) {
      return this; // Já está nos favoritos
    }
    return copyWith(
      favoriteProductIds: [...favoriteProductIds, productId],
    );
  }

  /// Remove um produto dos favoritos
  User removeFromFavorites(String productId) {
    final newFavorites =
        favoriteProductIds.where((id) => id != productId).toList();
    return copyWith(favoriteProductIds: newFavorites);
  }

  /// Adiciona uma lista ao usuário
  User addShoppingList(String listId) {
    if (shoppingListIds.contains(listId)) {
      return this;
    }
    return copyWith(
      shoppingListIds: [...shoppingListIds, listId],
    );
  }

  /// Remove uma lista do usuário
  User removeShoppingList(String listId) {
    final newLists = shoppingListIds.where((id) => id != listId).toList();
    return copyWith(shoppingListIds: newLists);
  }

  /// Total de favoritos
  int get favoritesCount => favoriteProductIds.length;

  /// Total de listas
  int get listsCount => shoppingListIds.length;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'favoriteProductIds': favoriteProductIds,
      'shoppingListIds': shoppingListIds,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Cria User a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      favoriteProductIds: List<String>.from(json['favoriteProductIds'] as List? ?? []),
      shoppingListIds: List<String>.from(json['shoppingListIds'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  /// Cria uma cópia com valores alterados
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    List<String>? favoriteProductIds,
    List<String>? shoppingListIds,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      shoppingListIds: shoppingListIds ?? this.shoppingListIds,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() =>
      'User(name: $name, email: $email, favorites: $favoritesCount, lists: $listsCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
