import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralized logger — never logs PII, tokens, or response bodies.
abstract class Logger {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
  void sanitizedError(DioException e);
}

class AppLogger implements Logger {
  const AppLogger();

  static const AppLogger instance = AppLogger();

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'RegistAgro',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'RegistAgro',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void sanitizedError(DioException e) {
    error(
      '[DioError] ${e.requestOptions.method} ${e.requestOptions.path} '
      'status=${e.response?.statusCode} type=${e.type.name}',
    );
  }
}
