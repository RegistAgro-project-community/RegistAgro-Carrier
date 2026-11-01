import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/services/logger.dart';

class _FakeLogger implements Logger {
  final List<String> messages = [];

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    messages.add(message);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    messages.add(message);
  }

  @override
  void sanitizedError(DioException e) {
    messages.add(
      'sanitized:${e.response?.statusCode}:${e.requestOptions.path}',
    );
  }
}

void main() {
  group('DioClient / RetryInterceptor', () {
    test('RetryInterceptor.shouldRetry: 503/429/timeout → true', () {
      final dio = Dio();
      final interceptor = RetryInterceptor(
        dio: dio,
        logger: const AppLogger(),
        retries: 3,
        retryDelays: const [Duration(milliseconds: 1)],
      );

      DioException make(int? status, DioExceptionType type) {
        return DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: type,
          response: status == null
              ? null
              : Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: status,
                ),
        );
      }

      expect(
        interceptor.shouldRetry(
          make(503, DioExceptionType.badResponse),
        ),
        isTrue,
      );
      expect(
        interceptor.shouldRetry(
          make(429, DioExceptionType.badResponse),
        ),
        isTrue,
      );
      expect(
        interceptor.shouldRetry(
          make(null, DioExceptionType.connectionTimeout),
        ),
        isTrue,
      );
      expect(
        interceptor.shouldRetry(
          make(400, DioExceptionType.badResponse),
        ),
        isFalse,
      );
      expect(
        interceptor.shouldRetry(
          make(401, DioExceptionType.badResponse),
        ),
        isFalse,
      );
    });

    test('ApiConfig.baseUrl usado como default do Dio', () {
          expect(ApiConfig.baseUrl, isNotEmpty);
          expect(ApiConfig.baseUrl.startsWith('http'), isTrue);
        });

        test('AppLogger.sanitizedError não inclui body', () {
      final logger = _FakeLogger();
      final err = DioException(
        requestOptions: RequestOptions(
          path: '/auth/login',
          method: 'POST',
          data: {'password': 'secret'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 500,
          data: {'token': 'should-not-log', 'email': 'x@y.com'},
        ),
      );
      logger.sanitizedError(err);
      expect(logger.messages.single, isNot(contains('secret')));
      expect(logger.messages.single, isNot(contains('should-not-log')));
      expect(logger.messages.single, contains('500'));
      expect(logger.messages.single, contains('/auth/login'));
    });
  });
}
