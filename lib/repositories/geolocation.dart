import 'package:dio/dio.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/models/direction_model.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/utils/safe_error.dart';

class GeoLocation implements IGeolocationRepository {
  @override
  Future<DirectionModel> getCoordinates(String requestId) async {
    try {
      final token = await TokenStorage().readToken();

      if (token.containsKey('error') || token['token'] == null) {
        throw Exception(token['error'] ?? SafeErrorMessages.sessionExpired);
      }

      final dio = DioClient().dio;
      final res = await dio.get(ApiConfig.carrierDirection(requestId));

      final List<dynamic> destinationData =
          res.data?['destination'] as List<dynamic>? ?? [];
      final List<dynamic> originData =
          res.data?['origin'] as List<dynamic>? ?? [];

      if (originData.isEmpty || destinationData.isEmpty) {
        throw Exception('Coordenadas não encontradas');
      }

      final List<double> originDouble = _parseCoordinate(originData);
      final List<double> destinationDouble = _parseCoordinate(destinationData);

      return DirectionModel(
        destination: destinationDouble,
        origin: originDouble,
        start_at: res.data['start_at'] as String?,
        update_at: res.data['update_at'] as String?,
      );
    } on DioException catch (e) {
      throw Exception(SafeErrorMessages.fromDio(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Ocorreu um erro inesperado ao obter localização');
    }
  }

  List<double> _parseCoordinate(List<dynamic> value) {
    return value.map((e) {
      if (e is num) return e.toDouble();
      if (e is String) {
        return double.tryParse(e) ??
            (throw Exception('Coordenada inválida'));
      }
      throw Exception('Tipo de coordenada inválido');
    }).toList();
  }
}
