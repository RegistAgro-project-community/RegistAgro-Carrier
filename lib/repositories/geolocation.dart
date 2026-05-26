import 'package:dio/dio.dart';
import 'package:registagrodriver/models/direction_model.dart';
import 'package:registagrodriver/repositories/storage.dart';

class GeoLocation {
  Future<DirectionModel> carrierCoordinates(String requestId) async {
    try {
      final token = await TokenStorage().readToken();

      if (token.containsKey("error") || token["token"] == null) {
        final message = token["error"] ?? "Faça login novamente";
        throw Exception(message);
      }

      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'authorization': "Bearer ${token['token']}",
          },
        ),
      );

      final res = await dio.get(
        "https://api-registagro.onrender.com/location/carrier/direction/request/$requestId",
      );

      final List<dynamic> destinationData = res.data?["destination"] as List<dynamic>? ?? [];
      final List<dynamic> originData = res.data?["origin"] as List<dynamic>? ?? [];

      if (originData.isEmpty || destinationData.isEmpty) {
        throw Exception("Coordenadas não encontradas");
      }

      final List<double> originDouble = _parseCoordinate(originData);
      final List<double> destinationDouble = _parseCoordinate(destinationData);

      return DirectionModel(
        destination: destinationDouble,
        origin: originDouble,
        start_at: res.data["start_at"],
        update_at: res.data["update_at"],
      );
    } on DioException catch (e) {
      String message = "Não foi possível obter a localização";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = e.response?.data?['error'] ?? 'Sessão expirada';
      } else {
        message =
            e.response?.data?['error'] ??
            e.response?.data?['info'] ??
            e.message ??
            message;
      }

      throw Exception(message);
    } catch (e) {
      throw Exception("Ocorreu um erro inesperado ao obter localização");
    }
  }

  List<double> _parseCoordinate(List<dynamic> value) {
    return value.map((e) {
      if (e is num) return e.toDouble();
      if (e is String) {
        return double.tryParse(e) ??
            (throw Exception("Coordenada inválida: $e"));
      }
      throw Exception("Tipo de coordenada inválido: ${e.runtimeType}");
    }).toList();
  }
}
