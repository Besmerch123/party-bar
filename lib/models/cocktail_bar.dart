class CocktailBar {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String ownerName;
  final List<String> cocktailIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String? imageUrl;
  final List<String> tags;

  const CocktailBar({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.cocktailIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.imageUrl,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'cocktailIds': cocktailIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  factory CocktailBar.fromMap(Map<String, dynamic> map) {
    return CocktailBar(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      cocktailIds: List<String>.from(map['cocktailIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isPublic: map['isPublic'] ?? false,
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  CocktailBar copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    List<String>? cocktailIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    String? imageUrl,
    List<String>? tags,
  }) {
    return CocktailBar(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      cocktailIds: cocktailIds ?? this.cocktailIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
    );
  }
}
