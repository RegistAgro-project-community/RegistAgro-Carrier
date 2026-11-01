import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/services/logger.dart';

typedef OnUnauthorized = FutureOr<void> Function();

/// Singleton Dio with auth interceptor, sanitized errors, and exponential retry.
class DioClient {
  DioClient._internal();

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;
  bool _initialized = false;
  OnUnauthorized? onUnauthorized;
  Logger _logger = AppLogger.instance;

  Dio get dio {
    if (!_initialized) {
      throw StateError('DioClient.init() must be called before use');
    }
    return _dio;
  }

  bool get isInitialized => _initialized;

  Future<void> init({
    TokenStorage? tokenStorage,
    Logger? logger,
    OnUnauthorized? onUnauthorizedCallback,
  }) async {
    if (_initialized) return;

    _logger = logger ?? AppLogger.instance;
    onUnauthorized = onUnauthorizedCallback;
    final storage = tokenStorage ?? TokenStorage();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra['startTime'] = DateTime.now();
          final tokenMap = await storage.readToken();
          if (!tokenMap.containsKey('error') && tokenMap['token'] != null) {
            options.headers['Authorization'] = 'Bearer ${tokenMap['token']}';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final start = response.requestOptions.extra['startTime'];
            if (start is DateTime) {
              final ms = DateTime.now().difference(start).inMilliseconds;
              _logger.debug(
                '[DioPerf] ${response.requestOptions.method} '
                '${response.requestOptions.path} ${ms}ms',
              );
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.sanitizedError(error);
          if (error.response?.statusCode == 401) {
            await storage.logout();
            await onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logger: _logger,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 3),
          Duration(seconds: 10),
        ],
      ),
    );

    _initialized = true;
  }

  /// Reset for tests only.
  @visibleForTesting
  void reset() {
    _initialized = false;
  }
}

/// Public retry interceptor (testable).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.logger,
    required this.retries,
    required this.retryDelays,
  });

  final Dio dio;
  final Logger logger;
  final int retries;
  final List<Duration> retryDelays;

  static const retryKey = '_retryCount';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!shouldRetry(err)) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra[retryKey] as int?) ?? 0;
    if (attempt >= retries) {
      return handler.next(err);
    }

    final delay = retryDelays[min(attempt, retryDelays.length - 1)];
    logger.debug(
      '[DioRetry] attempt ${attempt + 1}/$retries after ${delay.inSeconds}s '
      '→ ${err.requestOptions.path}',
    );
    await Future<void>.delayed(delay);

    final opts = err.requestOptions;
    opts.extra[retryKey] = attempt + 1;

    try {
      final response = await dio.fetch(opts);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool shouldRetry(DioException error) {
    final status = error.response?.statusCode;
    return status == 503 ||
        status == 429 ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}
