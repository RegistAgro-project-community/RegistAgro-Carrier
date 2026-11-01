import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class TokenStorage {
  static const _tokenKey = 'access_token';
  static const _carrierIdKey = 'carrier_id';

  Future<bool> storeToken(String token) async {
    try {
      await storage.write(key: _tokenKey, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> readToken() async {
    try {
      final token = await storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return {'error': 'Faça login novamente'};
      }
      return {'token': token};
    } catch (_) {
      return {'error': 'Ocorreu um erro inesperado'};
    }
  }

  Future<bool> storeCarrierId(String carrierId) async {
    try {
      await storage.write(key: _carrierIdKey, value: carrierId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> readCarrierId() async {
    try {
      return await storage.read(key: _carrierIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> logout() async {
    try {
      await storage.delete(key: _tokenKey);
      await storage.delete(key: _carrierIdKey);
      return {'message': 'Sessão terminada com sucesso'};
    } catch (_) {
      return {'error': 'Não foi possível terminar sessão'};
    }
  }
}
