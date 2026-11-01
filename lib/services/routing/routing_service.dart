import 'package:registagrodriver/models/geo_point.dart';

/// Route result from a routing provider (OSRM, etc.).
class RouteResult {
  final List<GeoPoint> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

/// Abstraction over routing engines (OCP / DIP).
abstract class RoutingService {
  Future<RouteResult> route(GeoPoint origin, GeoPoint destination);
}
