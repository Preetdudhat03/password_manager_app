import 'package:shared_preferences/shared_preferences.dart';

class UpdateCacheService {
  static const String _lastCheckKey = 'last_update_check_timestamp';

  /// Saves the current timestamp as the last check time.
  Future<void> saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Determines if an auto-check should run based on the 24-hour rule.
  Future<bool> shouldAutoCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);

    if (lastCheck == null) return true;

    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final difference = DateTime.now().difference(lastCheckTime);

    return difference.inHours >= 24;
  }
}
