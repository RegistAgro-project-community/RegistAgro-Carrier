import 'package:geocoding/geocoding.dart';

class LocationData {
  final String latitude;
  final String longitude;
  final String address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Geocoding with Angola bounding-box allowlist (SSRF mitigation).
abstract class Geocoder {
  Future<LocationData?> geocodeAddress(String address);
  bool isInAngola(double lat, double lon);
}

class GeocodingService implements Geocoder {
  static const List<String> allowedCountries = ['AO'];

  /// Bounding box approx. Angola: lat -18..-4, lon 11..24
  static const double minLat = -18;
  static const double maxLat = -4;
  static const double minLon = 11;
  static const double maxLon = 24;

  @override
  Future<LocationData?> geocodeAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      throw Exception('Endereço vazio');
    }

    final locations = await locationFromAddress(trimmed);
    if (locations.isEmpty) return null;

    final loc = locations.first;
    if (!isInAngola(loc.latitude, loc.longitude)) {
      throw Exception('Endereço fora da área de operação');
    }

    return LocationData(
      latitude: loc.latitude.toString(),
      longitude: loc.longitude.toString(),
      address: trimmed,
    );
  }

  @override
  bool isInAngola(double lat, double lon) {
    return lat >= minLat &&
        lat <= maxLat &&
        lon >= minLon &&
        lon <= maxLon;
  }

  /// Pure validation helper for tests without platform channels.
  static bool validateAngolaBounds(double lat, double lon) {
    return lat >= minLat &&
        lat <= maxLat &&
        lon >= minLon &&
        lon <= maxLon;
  }
}
