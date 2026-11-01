import 'package:dio/dio.dart';

/// Unified, anti-enumeration error messages for auth and API calls.
class SafeErrorMessages {
  SafeErrorMessages._();

  static const credentialsInvalid = 'Credenciais inválidas';
  static const serverError = 'Erro no servidor. Tente novamente mais tarde.';
  static const rateLimited = 'Muitas tentativas. Tente novamente mais tarde.';
  static const generic = 'Não foi possível concluir a solicitação.';
  static const captchaFailed = 'Verificação de segurança falhou';
  static const sessionExpired = 'Sessão expirada. Faça login novamente.';

  static String fromDio(DioException e) {
    return fromStatusCode(
      e.response?.statusCode,
      data: e.response?.data,
    );
  }

  static String fromStatusCode(int? statusCode, {dynamic data}) {
    switch (statusCode) {
      case 400:
        return _extractFieldErrors(data) ?? 'Dados inválidos';
      case 401:
      case 403:
        return credentialsInvalid;
      case 429:
        return rateLimited;
      case 500:
      case 502:
      case 503:
        return serverError;
      default:
        return generic;
    }
  }

  static String? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;

    final error = data['error'];
    if (error is List) {
      final messages = <String>[];
      for (final item in error) {
        if (item is String) {
          messages.add(_sanitize(item));
        } else if (item is Map && item['message'] is String) {
          messages.add(_sanitize(item['message'] as String));
        }
      }
      if (messages.isNotEmpty) return messages.join('\n');
    }

    if (error is String && error.isNotEmpty) {
      return _sanitize(error);
    }

    final info = data['info'];
    if (info is String && info.isNotEmpty) return _sanitize(info);

    return null;
  }

  static String _sanitize(String input) {
    var text = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(
          RegExp(r'(script|javascript|on\w+\s*=)', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(
            r'(union|select|insert|delete|drop)\s',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    if (text.length > 200) {
      text = text.substring(0, 200);
    }
    return text;
  }

  static String sanitize(String input) => _sanitize(input);
}
