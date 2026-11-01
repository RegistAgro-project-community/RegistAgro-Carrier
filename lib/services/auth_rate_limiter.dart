import 'package:shared_preferences/shared_preferences.dart';

/// Local auth rate limiter: 5 attempts / 15 min lockout.
class AuthRateLimiter {
  AuthRateLimiter({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const maxAttempts = 5;
  static const lockoutMinutes = 15;
  static const _keyPrefix = 'auth_attempts_';

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? SharedPreferences.getInstance();

  Future<bool> canAttempt(String identifier) async {
    final prefs = await _prefs;
    final key = '$_keyPrefix$identifier';
    final attempts = prefs.getInt(key) ?? 0;
    final lockedUntil = prefs.getInt('${key}_locked') ?? 0;

    if (lockedUntil > DateTime.now().millisecondsSinceEpoch) {
      return false;
    }

    // Lock expired — reset counter
    if (lockedUntil > 0 &&
        lockedUntil <= DateTime.now().millisecondsSinceEpoch) {
      await prefs.remove(key);
      await prefs.remove('${key}_locked');
      return true;
    }

    return attempts < maxAttempts;
  }

  Future<void> recordAttempt(String identifier, bool success) async {
    final prefs = await _prefs;
    final key = '$_keyPrefix$identifier';

    if (success) {
      await prefs.remove(key);
      await prefs.remove('${key}_locked');
      return;
    }

    final attempts = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, attempts);

    if (attempts >= maxAttempts) {
      final lockUntil = DateTime.now()
          .add(const Duration(minutes: lockoutMinutes))
          .millisecondsSinceEpoch;
      await prefs.setInt('${key}_locked', lockUntil);
    }
  }

  Future<int?> getRemainingMinutes(String identifier) async {
    final prefs = await _prefs;
    final lockedUntil = prefs.getInt('$_keyPrefix${identifier}_locked') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lockedUntil > now) {
      return ((lockedUntil - now) / 60000).ceil();
    }
    return null;
  }

  Future<void> reset(String identifier) async {
    final prefs = await _prefs;
    final key = '$_keyPrefix$identifier';
    await prefs.remove(key);
    await prefs.remove('${key}_locked');
  }
}
