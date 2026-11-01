import 'package:dio/dio.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/utils/safe_error.dart';

/// Auth repository — SRP: API auth only (no UI).
class AuthRepository implements IAuthRepository {
  AuthRepository({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio? _dio;
  final TokenStorage _tokenStorage;

  Dio get _client => _dio ?? DioClient().dio;

  @override
  Future<Map<String, String>> login(
    String email,
    String password, {
    String? captchaToken,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (captchaToken != null && captchaToken.isNotEmpty) {
      data['captchaToken'] = captchaToken;
    }

    try {
      final res = await _client.post(ApiConfig.carrierLogin, data: data);

      final authHeader = res.headers.value('authorization');
      final token = authHeader?.split(' ').last;

      if (token == null || token.isEmpty) {
        return {'error': SafeErrorMessages.generic};
      }

      final stored = await _tokenStorage.storeToken(token);
      if (!stored) {
        return {'error': SafeErrorMessages.generic};
      }

      final userId =
          res.data is Map ? res.data['userId'] ?? res.data['id'] : null;
      if (userId is String && userId.isNotEmpty) {
        await _tokenStorage.storeCarrierId(userId);
      }

      return {
        'message': res.data['message']?.toString() ?? 'Login efectuado',
      };
    } on DioException catch (e) {
      return {'error': SafeErrorMessages.fromDio(e)};
    }
  }
}

/// Thin wrapper kept for existing call sites (migration path).
Future<Map<String, String>> login(
  dynamic context,
  String email,
  String password, {
  String? captchaToken,
}) {
  return AuthRepository().login(
    email,
    password,
    captchaToken: captchaToken,
  );
}
