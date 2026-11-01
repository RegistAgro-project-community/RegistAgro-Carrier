import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registagrodriver/utils/auth_validators.dart';
import 'package:registagrodriver/utils/safe_error.dart';
import 'package:registagrodriver/utils/upload_validator.dart';

void main() {
  group('AuthValidators', () {
    test('email válido / inválido', () {
      expect(AuthValidators.validateEmail(null), isNotNull);
      expect(AuthValidators.validateEmail(''), isNotNull);
      expect(AuthValidators.validateEmail('bad'), isNotNull);
      expect(AuthValidators.validateEmail('a@b.com'), isNull);
    });

    test('password mínimo 8', () {
      expect(AuthValidators.validatePassword('short'), isNotNull);
      expect(AuthValidators.validatePassword('longenough'), isNull);
    });

    test('otp 6 dígitos', () {
      expect(AuthValidators.validateOtp('123'), isNotNull);
      expect(AuthValidators.validateOtp('abcdef'), isNotNull);
      expect(AuthValidators.validateOtp('123456'), isNull);
    });
  });

  group('SafeErrorMessages', () {
    test('401/403 → Credenciais inválidas', () {
      expect(
        SafeErrorMessages.fromStatusCode(401),
        SafeErrorMessages.credentialsInvalid,
      );
      expect(
        SafeErrorMessages.fromStatusCode(403),
        SafeErrorMessages.credentialsInvalid,
      );
    });

    test('429 → rate limited', () {
      expect(
        SafeErrorMessages.fromStatusCode(429),
        SafeErrorMessages.rateLimited,
      );
    });

    test('500 → server error', () {
      expect(
        SafeErrorMessages.fromStatusCode(500),
        SafeErrorMessages.serverError,
      );
    });

    test('400 → mostra campos', () {
      final msg = SafeErrorMessages.fromStatusCode(
        400,
        data: {
          'error': [
            {'message': 'Email inválido'},
          ],
        },
      );
      expect(msg, contains('Email inválido'));
    });

    test('sanitize remove HTML/scripts', () {
      final clean = SafeErrorMessages.sanitize(
        '<script>alert(1)</script>Olá mundo',
      );
      expect(clean, isNot(contains('<script>')));
      expect(clean, contains('Olá mundo'));
    });

    test('fromDio usa status code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 401,
        ),
      );
      expect(SafeErrorMessages.fromDio(err), SafeErrorMessages.credentialsInvalid);
    });
  });

  group('UploadValidator', () {
    test('extensões permitidas', () {
      expect(UploadValidator.isAllowedExtension('a.jpg'), isTrue);
      expect(UploadValidator.isAllowedExtension('a.PNG'), isTrue);
      expect(UploadValidator.isAllowedExtension('a.gif'), isFalse);
      expect(UploadValidator.isAllowedExtension('a.exe'), isFalse);
    });
  });
}
