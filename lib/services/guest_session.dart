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

  /// Flow 08 · screen 07 — the party whose recap this phone can still read,
  /// and when the night ended. A different key from [_partyKey] on purpose:
  /// the binding dies with the party, the recap outlives it.
  static const _recapKey = 'guest_recap_party_id';
  static const _recapEndedKey = 'guest_recap_ended_at';

  /// "This page stays on your phone for a week." Then it lets go.
  static const recapLifetime = Duration(days: 7);

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

  /// Called the moment the host closes the bar. Keeping the id rather than
  /// the numbers means the recap is read fresh from the party's own orders —
  /// a drink the host served after the guest pocketed their phone still
  /// counts when the page is opened in the morning.
  static Future<void> rememberRecap(String partyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recapKey, partyId);
    await prefs.setInt(
      _recapEndedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// The recap this phone can still read, or null once the week is up. An
  /// expired one clears itself here rather than waiting for a sweep that
  /// nothing would ever run.
  static Future<String?> recapPartyId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_recapKey);
    if (id == null) return null;

    final endedAt = prefs.getInt(_recapEndedKey);
    if (endedAt == null) return id;

    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(endedAt),
    );
    if (age < recapLifetime) return id;

    await forgetRecap();
    return null;
  }

  static Future<void> forgetRecap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recapKey);
    await prefs.remove(_recapEndedKey);
  }
}
