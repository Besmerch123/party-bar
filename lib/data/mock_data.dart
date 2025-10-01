import '../models/models.dart';

class MockData {
  // Mock Users
  static final List<User> users = [
    User(
      id: 'user1',
      name: 'John Doe',
      email: 'john@example.com',
      favoriteCoktailIds: [],
      allergens: ['nuts'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    ),
    User(
      id: 'user2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      favoriteCoktailIds: [],
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
      availableCocktailIds: [],
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
      availableCocktailIds: [],
      joinCode: 'BDAY456',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      totalOrders: 5,
      description: 'Celebrating another year around the sun!',
    ),
  ];

  // Mock Orders
  // Note: cocktailIds are placeholder strings - replace with real IDs from Firestore
  static final List<CocktailOrder> orders = [
    CocktailOrder(
      id: 'order1',
      partyId: 'party1',
      cocktailId: 'cocktail_id_placeholder_1',
      guestName: 'Alice Johnson',
      status: OrderStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      preparedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    CocktailOrder(
      id: 'order2',
      partyId: 'party1',
      cocktailId: 'cocktail_id_placeholder_2',
      guestName: 'Bob Wilson',
      specialRequests: 'Extra mint please',
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    CocktailOrder(
      id: 'order3',
      partyId: 'party1',
      cocktailId: 'cocktail_id_placeholder_3',
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
      cocktailIds: [],
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
      cocktailIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isPublic: true,
      tags: ['summer', 'refreshing', 'tropical'],
    ),
  ];

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
