/// Seed data for Flow 01 · Onboarding.
///
/// The flow promises two numbers before an account exists — "you can pour 14"
/// and "one lime unlocks 11 more". Neither can come from Firestore yet: there
/// is no aggregate that answers "what can this shelf make". Until there is,
/// the starter catalogue below carries the weights itself, so the flow is
/// honest about being a curated first-run list rather than a live query.
library;

import 'package:flutter/material.dart';

/// A flavour direction picked on step 04. Seeds ordering in Explore; it never
/// hides anything.
enum DrinkVibe {
  sharpCitrus(image: 'assets/images/onboarding/cosmopolitan.jpg'),
  darkStirred(image: 'assets/images/onboarding/midnight_orchard.jpg'),
  longFizzy(image: 'assets/images/onboarding/gin_tonic.jpg'),
  spicy(icon: Icons.local_fire_department),
  zeroProof(icon: Icons.no_drinks),
  threeIngredients(icon: Icons.bolt);

  const DrinkVibe({this.image, this.icon});

  /// Photo tile. Mutually exclusive with [icon].
  final String? image;

  /// Flat tile glyph, used where no photograph earns the space.
  final IconData? icon;
}

/// A bottle or mixer offered on step 05.
class StarterBottle {
  const StarterBottle({
    required this.id,
    required this.icon,
    required this.cocktailCount,
    required this.unlocks,
    this.image,
  });

  /// Stable key — persisted, and used to look the bottle's label up in l10n.
  final String id;

  final IconData icon;

  /// Editorial "in N cocktails" figure shown on the row.
  final int cocktailCount;

  /// How many drinks this bottle adds to the pourable total once the rest of
  /// the shelf is accounted for. Deliberately smaller than [cocktailCount]:
  /// most recipes need more than one thing.
  final int unlocks;

  /// Optional photograph; bottles without one fall back to [icon].
  final String? image;
}

/// The curated first-run shelf. Ordered as it appears under
/// "MOST HOME BARS HAVE THESE".
const kStarterBottles = <StarterBottle>[
  StarterBottle(
    id: 'gin',
    icon: Icons.liquor,
    cocktailCount: 34,
    unlocks: 6,
    image: 'assets/images/onboarding/gin.jpg',
  ),
  StarterBottle(id: 'vodka', icon: Icons.liquor, cocktailCount: 41, unlocks: 5),
  StarterBottle(id: 'tonic', icon: Icons.wine_bar, cocktailCount: 12, unlocks: 3),
  StarterBottle(id: 'lime', icon: Icons.eco, cocktailCount: 26, unlocks: 11),
  StarterBottle(id: 'whiteRum', icon: Icons.liquor, cocktailCount: 28, unlocks: 5),
  StarterBottle(
    id: 'sweetVermouth',
    icon: Icons.coffee,
    cocktailCount: 19,
    unlocks: 4,
  ),
  StarterBottle(id: 'whiskey', icon: Icons.liquor, cocktailCount: 31, unlocks: 5),
  StarterBottle(id: 'tequila', icon: Icons.liquor, cocktailCount: 22, unlocks: 4),
  StarterBottle(id: 'tripleSec', icon: Icons.liquor, cocktailCount: 17, unlocks: 4),
  StarterBottle(id: 'lemon', icon: Icons.eco, cocktailCount: 24, unlocks: 6),
  StarterBottle(id: 'simpleSyrup', icon: Icons.water_drop, cocktailCount: 29, unlocks: 7),
  StarterBottle(id: 'sodaWater', icon: Icons.bubble_chart, cocktailCount: 15, unlocks: 3),
  StarterBottle(id: 'angostura', icon: Icons.medication_liquid, cocktailCount: 13, unlocks: 3),
  StarterBottle(id: 'mint', icon: Icons.grass, cocktailCount: 9, unlocks: 2),
];

/// How many bottles step 05 asks for. Five, not twenty — enough to make the
/// unlock number honest, short enough to finish.
const kStarterBottleTarget = 5;
