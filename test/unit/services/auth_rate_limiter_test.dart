import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:registagrodriver/services/auth_rate_limiter.dart';

void main() {
  group('AuthRateLimiter', () {
    late AuthRateLimiter limiter;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      limiter = AuthRateLimiter(prefs: prefs);
    });

    test('canAttempt: <5 tentativas → true', () async {
      expect(await limiter.canAttempt('a@b.com'), isTrue);
      await limiter.recordAttempt('a@b.com', false);
      await limiter.recordAttempt('a@b.com', false);
      expect(await limiter.canAttempt('a@b.com'), isTrue);
    });

    test('canAttempt: ≥5 tentativas → false', () async {
      for (var i = 0; i < AuthRateLimiter.maxAttempts; i++) {
        await limiter.recordAttempt('lock@test.com', false);
      }
      expect(await limiter.canAttempt('lock@test.com'), isFalse);
    });

    test('recordAttempt: sucesso → reseta contador', () async {
      for (var i = 0; i < 3; i++) {
        await limiter.recordAttempt('ok@test.com', false);
      }
      await limiter.recordAttempt('ok@test.com', true);
      expect(await limiter.canAttempt('ok@test.com'), isTrue);
      expect(await limiter.getRemainingMinutes('ok@test.com'), isNull);
    });

    test('lockout: getRemainingMinutes > 0', () async {
      for (var i = 0; i < AuthRateLimiter.maxAttempts; i++) {
        await limiter.recordAttempt('mins@test.com', false);
      }
      final mins = await limiter.getRemainingMinutes('mins@test.com');
      expect(mins, isNotNull);
      expect(mins!, greaterThan(0));
      expect(mins, lessThanOrEqualTo(AuthRateLimiter.lockoutMinutes));
    });
  });
}
