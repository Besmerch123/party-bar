import '../models/models.dart';

class MockData {
  // Mock Cocktails
  static final List<Cocktail> cocktails = [
    // Classic cocktails
    const Cocktail(
      id: '1',
      name: 'Old Fashioned',
      description: 'A classic whiskey cocktail with bitters and sugar',
      ingredients: [
        CocktailIngredient(name: 'Bourbon Whiskey', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Sugar Cube', amount: '1'),
        CocktailIngredient(
          name: 'Angostura Bitters',
          amount: '2-3',
          unit: 'dashes',
        ),
        CocktailIngredient(name: 'Orange Peel', amount: '1'),
        CocktailIngredient(name: 'Ice', amount: '1', unit: 'cube'),
      ],
      instructions: [
        'Place sugar cube in old fashioned glass',
        'Saturate with bitters and muddle',
        'Add whiskey',
        'Add ice cube',
        'Stir gently',
        'Express orange peel oils over glass and drop in',
      ],
      category: CocktailCategory.classic,
      difficulty: CocktailDifficulty.medium,
      prepTimeMinutes: 3,
      alcoholContent: 35.0,
      isPopular: true,
      tags: ['whiskey', 'classic', 'strong'],
    ),
    const Cocktail(
      id: '2',
      name: 'Margarita',
      description: 'Classic tequila cocktail with lime and triple sec',
      ingredients: [
        CocktailIngredient(name: 'Tequila', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Triple Sec', amount: '1', unit: 'oz'),
        CocktailIngredient(name: 'Lime Juice', amount: '1', unit: 'oz'),
        CocktailIngredient(
          name: 'Salt',
          amount: '1',
          unit: 'pinch',
          isOptional: true,
        ),
        CocktailIngredient(name: 'Ice', amount: '1', unit: 'cup'),
      ],
      instructions: [
        'Salt rim of glass (optional)',
        'Add all ingredients to shaker with ice',
        'Shake vigorously',
        'Strain into glass over fresh ice',
        'Garnish with lime wheel',
      ],
      category: CocktailCategory.classic,
      difficulty: CocktailDifficulty.easy,
      prepTimeMinutes: 2,
      alcoholContent: 22.0,
      isPopular: true,
      tags: ['tequila', 'citrus', 'refreshing'],
    ),
    const Cocktail(
      id: '3',
      name: 'Mojito',
      description: 'Refreshing rum cocktail with mint and lime',
      ingredients: [
        CocktailIngredient(name: 'White Rum', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Fresh Lime Juice', amount: '1', unit: 'oz'),
        CocktailIngredient(name: 'Simple Syrup', amount: '0.5', unit: 'oz'),
        CocktailIngredient(name: 'Fresh Mint Leaves', amount: '6-8'),
        CocktailIngredient(name: 'Soda Water', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Ice', amount: '1', unit: 'cup'),
      ],
      instructions: [
        'Muddle mint leaves in glass',
        'Add lime juice and simple syrup',
        'Add rum and ice',
        'Top with soda water',
        'Stir gently',
        'Garnish with mint sprig',
      ],
      category: CocktailCategory.rum,
      difficulty: CocktailDifficulty.easy,
      prepTimeMinutes: 3,
      alcoholContent: 15.0,
      isPopular: true,
      tags: ['rum', 'mint', 'refreshing', 'summer'],
    ),
    const Cocktail(
      id: '4',
      name: 'Espresso Martini',
      description: 'Modern cocktail combining vodka with fresh espresso',
      ingredients: [
        CocktailIngredient(name: 'Vodka', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Fresh Espresso', amount: '1', unit: 'oz'),
        CocktailIngredient(name: 'Coffee Liqueur', amount: '0.5', unit: 'oz'),
        CocktailIngredient(name: 'Simple Syrup', amount: '0.25', unit: 'oz'),
        CocktailIngredient(name: 'Coffee Beans', amount: '3', isOptional: true),
      ],
      instructions: [
        'Add all ingredients to shaker with ice',
        'Shake vigorously for 15 seconds',
        'Double strain into chilled martini glass',
        'Garnish with 3 coffee beans',
      ],
      category: CocktailCategory.modern,
      difficulty: CocktailDifficulty.medium,
      prepTimeMinutes: 4,
      alcoholContent: 25.0,
      isPopular: true,
      tags: ['vodka', 'coffee', 'modern', 'after-dinner'],
    ),
    const Cocktail(
      id: '5',
      name: 'Piña Colada',
      description: 'Tropical rum cocktail with coconut and pineapple',
      ingredients: [
        CocktailIngredient(name: 'White Rum', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Coconut Cream', amount: '1', unit: 'oz'),
        CocktailIngredient(name: 'Pineapple Juice', amount: '3', unit: 'oz'),
        CocktailIngredient(name: 'Crushed Ice', amount: '1', unit: 'cup'),
        CocktailIngredient(
          name: 'Pineapple Wedge',
          amount: '1',
          isOptional: true,
        ),
      ],
      instructions: [
        'Add all ingredients to blender',
        'Blend until smooth',
        'Pour into hurricane glass',
        'Garnish with pineapple wedge and cherry',
      ],
      category: CocktailCategory.tropical,
      difficulty: CocktailDifficulty.easy,
      prepTimeMinutes: 2,
      alcoholContent: 12.0,
      isPopular: true,
      tags: ['rum', 'tropical', 'sweet', 'vacation'],
    ),
    const Cocktail(
      id: '6',
      name: 'Manhattan',
      description: 'Classic whiskey cocktail with sweet vermouth',
      ingredients: [
        CocktailIngredient(name: 'Rye Whiskey', amount: '2', unit: 'oz'),
        CocktailIngredient(name: 'Sweet Vermouth', amount: '1', unit: 'oz'),
        CocktailIngredient(
          name: 'Angostura Bitters',
          amount: '2',
          unit: 'dashes',
        ),
        CocktailIngredient(name: 'Maraschino Cherry', amount: '1'),
      ],
      instructions: [
        'Add whiskey, vermouth, and bitters to mixing glass with ice',
        'Stir until well chilled',
        'Strain into chilled coupe glass',
        'Garnish with maraschino cherry',
      ],
      category: CocktailCategory.classic,
      difficulty: CocktailDifficulty.medium,
      prepTimeMinutes: 3,
      alcoholContent: 30.0,
      tags: ['whiskey', 'classic', 'sophisticated'],
    ),
    const Cocktail(
      id: '7',
      name: 'Cosmopolitan',
      description: 'Modern vodka cocktail with cranberry and lime',
      ingredients: [
        CocktailIngredient(name: 'Vodka', amount: '1.5', unit: 'oz'),
        CocktailIngredient(name: 'Triple Sec', amount: '0.5', unit: 'oz'),
        CocktailIngredient(name: 'Cranberry Juice', amount: '0.75', unit: 'oz'),
        CocktailIngredient(name: 'Fresh Lime Juice', amount: '0.5', unit: 'oz'),
        CocktailIngredient(name: 'Lime Wheel', amount: '1'),
      ],
      instructions: [
        'Add all ingredients to shaker with ice',
        'Shake vigorously',
        'Double strain into chilled martini glass',
        'Garnish with lime wheel',
      ],
      category: CocktailCategory.modern,
      difficulty: CocktailDifficulty.easy,
      prepTimeMinutes: 3,
      alcoholContent: 18.0,
      tags: ['vodka', 'cranberry', 'citrus', 'pink'],
    ),
    const Cocktail(
      id: '8',
      name: 'Virgin Mojito',
      description: 'Refreshing non-alcoholic version of the classic mojito',
      ingredients: [
        CocktailIngredient(name: 'Fresh Lime Juice', amount: '1', unit: 'oz'),
        CocktailIngredient(name: 'Simple Syrup', amount: '0.75', unit: 'oz'),
        CocktailIngredient(name: 'Fresh Mint Leaves', amount: '8-10'),
        CocktailIngredient(name: 'Soda Water', amount: '4', unit: 'oz'),
        CocktailIngredient(name: 'Ice', amount: '1', unit: 'cup'),
      ],
      instructions: [
        'Muddle mint leaves in glass',
        'Add lime juice and simple syrup',
        'Fill with ice',
        'Top with soda water',
        'Stir gently',
        'Garnish with mint sprig and lime wheel',
      ],
      category: CocktailCategory.mocktail,
      difficulty: CocktailDifficulty.easy,
      prepTimeMinutes: 2,
      alcoholContent: 0.0,
      tags: ['non-alcoholic', 'mint', 'refreshing', 'healthy'],
    ),
  ];

  // Mock Users
  static final List<User> users = [
    User(
      id: 'user1',
      name: 'John Doe',
      email: 'john@example.com',
      favoriteCoktailIds: ['1', '3', '4'],
      allergens: ['nuts'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    ),
    User(
      id: 'user2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      favoriteCoktailIds: ['2', '7', '8'],
      allergens: ['shellfish'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // Mock Parties
  static final List<Party> parties = [
    Party(
      id: 'party1',
      name: 'Weekend House Party',
      hostId: 'user1',
      hostName: 'John Doe',
      availableCocktailIds: ['1', '2', '3', '4', '8'],
      joinCode: 'PARTY123',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalOrders: 12,
      description: 'Join us for a fun weekend party with amazing cocktails!',
    ),
    Party(
      id: 'party2',
      name: 'Birthday Celebration',
      hostId: 'user2',
      hostName: 'Jane Smith',
      availableCocktailIds: ['2', '5', '7', '8'],
      joinCode: 'BDAY456',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      totalOrders: 5,
      description: 'Celebrating another year around the sun!',
    ),
  ];

  // Mock Orders
  static final List<CocktailOrder> orders = [
    CocktailOrder(
      id: 'order1',
      partyId: 'party1',
      cocktailId: '1',
      guestName: 'Alice Johnson',
      status: OrderStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      preparedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    CocktailOrder(
      id: 'order2',
      partyId: 'party1',
      cocktailId: '3',
      guestName: 'Bob Wilson',
      specialRequests: 'Extra mint please',
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    CocktailOrder(
      id: 'order3',
      partyId: 'party1',
      cocktailId: '8',
      guestName: 'Carol Davis',
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // Mock Cocktail Bars
  static final List<CocktailBar> cocktailBars = [
    CocktailBar(
      id: 'bar1',
      name: 'Classic Collection',
      description: 'A collection of timeless classic cocktails',
      ownerId: 'user1',
      ownerName: 'John Doe',
      cocktailIds: ['1', '6', '2'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isPublic: true,
      tags: ['classic', 'timeless', 'sophisticated'],
    ),
    CocktailBar(
      id: 'bar2',
      name: 'Summer Vibes',
      description: 'Refreshing cocktails perfect for summer',
      ownerId: 'user2',
      ownerName: 'Jane Smith',
      cocktailIds: ['3', '5', '8'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isPublic: true,
      tags: ['summer', 'refreshing', 'tropical'],
    ),
  ];

  // Helper methods to get cocktails by category
  static List<Cocktail> getCocktailsByCategory(CocktailCategory category) {
    return cocktails
        .where((cocktail) => cocktail.category == category)
        .toList();
  }

  // Helper method to get popular cocktails
  static List<Cocktail> getPopularCocktails() {
    return cocktails.where((cocktail) => cocktail.isPopular).toList();
  }

  // Helper method to get cocktails by difficulty
  static List<Cocktail> getCocktailsByDifficulty(
    CocktailDifficulty difficulty,
  ) {
    return cocktails
        .where((cocktail) => cocktail.difficulty == difficulty)
        .toList();
  }

  // Helper method to search cocktails
  static List<Cocktail> searchCocktails(String query) {
    final lowerQuery = query.toLowerCase();
    return cocktails.where((cocktail) {
      return cocktail.name.toLowerCase().contains(lowerQuery) ||
          cocktail.description.toLowerCase().contains(lowerQuery) ||
          cocktail.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          cocktail.ingredients.any(
            (ingredient) => ingredient.name.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  // Helper method to get cocktail by ID
  static Cocktail? getCocktailById(String id) {
    try {
      return cocktails.firstWhere((cocktail) => cocktail.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get party by join code
  static Party? getPartyByJoinCode(String joinCode) {
    try {
      return parties.firstWhere((party) => party.joinCode == joinCode);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get orders for a party
  static List<CocktailOrder> getOrdersForParty(String partyId) {
    return orders.where((order) => order.partyId == partyId).toList();
  }
}
