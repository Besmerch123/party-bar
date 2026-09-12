import 'package:shared_preferences/shared_preferences.dart';

/// Flow 07 — what the phone keeps between openings: the party this guest is
/// at tonight. Close the app, lose signal, walk out to the balcony — coming
/// back lands on the same menu instead of the code screen.
///
/// The display name is *not* kept here. That lives in
/// `AuthenticationProvider.guestName`, which already outlives a single party:
/// a guest is asked their name once, not once per party. This remembers only
/// the binding, and drops it the moment the host closes the bar.
///
/// The device id a guest's orders are written under is
/// [GuestIdentity.deviceId] — a different thing, and permanent.
abstract final class GuestSession {
  static const _partyKey = 'guest_party_id';

  /// The party this phone is at, or null once the night is over.
  static Future<String?> partyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_partyKey);
  }

  static Future<void> remember(String partyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_partyKey, partyId);
  }

  /// Called when the party ends and when a guest leaves it deliberately.
  /// Forgetting a party that was never remembered is a no-op, so callers
  /// never have to check first.
  static Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_partyKey);
  }
}
