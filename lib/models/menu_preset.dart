/// Flow 08 · screen 05 — a menu that outlived the party it was poured at.
///
/// The recipes travel; the party does not. A preset is a name and an ordered
/// list of cocktail ids — no code, no guests, no host — so reopening it next
/// month builds a fresh party with the same drinks in the same order.
library;

class MenuPreset {
  const MenuPreset({
    required this.id,
    required this.name,
    required this.cocktailIds,
    required this.savedAt,
  });

  final String id;
  final String name;

  /// In the order the host had them.
  final List<String> cocktailIds;

  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cocktailIds': cocktailIds,
    'savedAt': savedAt.toIso8601String(),
  };

  factory MenuPreset.fromJson(Map<String, dynamic> json) => MenuPreset(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    cocktailIds: List<String>.from(json['cocktailIds'] as List? ?? const []),
    savedAt:
        DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
