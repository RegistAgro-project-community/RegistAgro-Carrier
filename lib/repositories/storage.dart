import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class TokenStorage {
  Future<dynamic> storeToken(String token) async {
    try {
      await storage.write(key: 'access_token', value: token);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> readToken() async {
    try {
      final token = await storage.read(key: 'access_token');

      return {'token': token!};
    } catch (e) {
      return {'error': "Ocorreu um erro inesperado"};
    }
  }

  Future<Map<String, String>> logout() async {
    try {
      await storage.delete(key: 'access_token');

      return {'message': "Sessão terminada com sucesso"};
    } catch (e) {
      return {'error': "Não foi possível terminar sessão"};
    }
  }
}
