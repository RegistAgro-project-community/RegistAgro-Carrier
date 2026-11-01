import 'package:dio/dio.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/models/geo_point.dart';
import 'package:registagrodriver/services/geocoding_service.dart';
import 'package:registagrodriver/services/logger.dart';
import 'package:registagrodriver/services/routing/routing_service.dart';

/// OSRM public router — same stack as RegistAgro Web (OSM + OSRM).
class OsrmRoutingService implements RoutingService {
  OsrmRoutingService({
    Dio? dio,
    Logger? logger,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Accept': 'application/json'},
              ),
            ),
        _logger = logger ?? AppLogger.instance,
        _baseUrl = baseUrl ?? ApiConfig.osrmBaseUrl;

  final Dio _dio;
  final Logger _logger;
  final String _baseUrl;

  @override
  Future<RouteResult> route(GeoPoint origin, GeoPoint destination) async {
    if (!GeocodingService.validateAngolaBounds(
          origin.latitude,
          origin.longitude,
        ) ||
        !GeocodingService.validateAngolaBounds(
          destination.latitude,
          destination.longitude,
        )) {
      throw Exception('Rota fora da área de operação (Angola)');
    }

    // OSRM expects lon,lat
    final path =
        '$_baseUrl/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';

    try {
      final res = await _dio.get(
        path,
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      final routes = res.data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw Exception('Nenhuma rota encontrada');
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>? ?? [];

      final points = coords.map((c) {
        final pair = c as List<dynamic>;
        return GeoPoint(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points: points,
        distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      );
    } on DioException catch (e) {
      _logger.sanitizedError(e);
      throw Exception('Não foi possível calcular a rota');
    }
  }
}
