enum CocktailCategory {
  classic,
  modern,
  shots,
  tropical,
  martini,
  whiskey,
  vodka,
  rum,
  gin,
  mocktail,
}

enum CocktailDifficulty { easy, medium, hard }

class CocktailIngredient {
  final String name;
  final String amount;
  final String? unit;
  final bool isOptional;

  const CocktailIngredient({
    required this.name,
    required this.amount,
    this.unit,
    this.isOptional = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'isOptional': isOptional,
    };
  }

  factory CocktailIngredient.fromMap(Map<String, dynamic> map) {
    return CocktailIngredient(
      name: map['name'] ?? '',
      amount: map['amount'] ?? '',
      unit: map['unit'],
      isOptional: map['isOptional'] ?? false,
    );
  }
}

class Cocktail {
  final String id;
  final String name;
  final String description;
  final List<CocktailIngredient> ingredients;
  final List<String> instructions;
  final CocktailCategory category;
  final CocktailDifficulty difficulty;
  final int prepTimeMinutes;
  final String? imageUrl;
  final List<String> tags;
  final double alcoholContent;
  final bool isPopular;

  const Cocktail({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
    required this.difficulty,
    required this.prepTimeMinutes,
    this.imageUrl,
    this.tags = const [],
    required this.alcoholContent,
    this.isPopular = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'instructions': instructions,
      'category': category.name,
      'difficulty': difficulty.name,
      'prepTimeMinutes': prepTimeMinutes,
      'imageUrl': imageUrl,
      'tags': tags,
      'alcoholContent': alcoholContent,
      'isPopular': isPopular,
    };
  }

  factory Cocktail.fromMap(Map<String, dynamic> map) {
    return Cocktail(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<CocktailIngredient>.from(
        map['ingredients']?.map((x) => CocktailIngredient.fromMap(x)) ?? [],
      ),
      instructions: List<String>.from(map['instructions'] ?? []),
      category: CocktailCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => CocktailCategory.modern,
      ),
      difficulty: CocktailDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => CocktailDifficulty.medium,
      ),
      prepTimeMinutes: map['prepTimeMinutes']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      alcoholContent: map['alcoholContent']?.toDouble() ?? 0.0,
      isPopular: map['isPopular'] ?? false,
    );
  }

  Cocktail copyWith({
    String? id,
    String? name,
    String? description,
    List<CocktailIngredient>? ingredients,
    List<String>? instructions,
    CocktailCategory? category,
    CocktailDifficulty? difficulty,
    int? prepTimeMinutes,
    String? imageUrl,
    List<String>? tags,
    double? alcoholContent,
    bool? isPopular,
  }) {
    return Cocktail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      alcoholContent: alcoholContent ?? this.alcoholContent,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
