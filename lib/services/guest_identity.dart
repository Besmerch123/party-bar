import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A guest orders on a name alone, with no account — but "your round" still
/// has to find this phone's orders among everyone's. This is the phone's
/// half of that: a random id minted once and kept, written onto every order
/// it sends.
abstract final class GuestIdentity {
  static const _key = 'guest_device_id';

  static String? _cached;

  static Future<String> deviceId() async {
    if (_cached case final id?) return id;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    return _cached = id;
  }
}
