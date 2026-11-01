import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:registagrodriver/models/geo_point.dart';
import 'package:registagrodriver/repositories/geolocation.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/services/geocoding_service.dart';
import 'package:registagrodriver/services/logger.dart';
import 'package:registagrodriver/services/routing/routing_service.dart';
import 'package:registagrodriver/utils/safe_error.dart';

/// Location + route state — depends on abstractions (DIP).
class SourceLocationProvider extends ChangeNotifier {
  SourceLocationProvider({
    IGeolocationRepository? geolocation,
    RoutingService? routing,
    Geocoder? geocoder,
    Logger? logger,
  })  : _geolocation = geolocation ?? GeoLocation(),
        _routing = routing,
        _geocoder = geocoder ?? GeocodingService(),
        _logger = logger ?? AppLogger.instance;

  final IGeolocationRepository _geolocation;
  final RoutingService? _routing;
  final Geocoder _geocoder;
  final Logger _logger;

  GeoPoint? _currentPoint;
  GeoPoint? _destinationPoint;
  List<GeoPoint> _routePoints = const [];
  String _currentAddress = '';
  String _destinationAddress = '';
  bool _isLoading = false;
  String? _error;

  GeoPoint? get currentPoint => _currentPoint;
  GeoPoint? get destinationPoint => _destinationPoint;
  List<GeoPoint> get routePoints => _routePoints;
  String get currentAddress => _currentAddress;
  String get destinationAddress => _destinationAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentLocation(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coords = await _geolocation.getCoordinates(requestId);

      _currentPoint = GeoPoint(coords.origin[0], coords.origin[1]);
      _destinationPoint =
          GeoPoint(coords.destination[0], coords.destination[1]);

      if (!_geocoder.isInAngola(
            _currentPoint!.latitude,
            _currentPoint!.longitude,
          ) ||
          !_geocoder.isInAngola(
            _destinationPoint!.latitude,
            _destinationPoint!.longitude,
          )) {
        throw Exception('Endereço fora da área de operação');
      }

      _currentAddress = await _getAddress(_currentPoint!);
      _destinationAddress = await _getAddress(_destinationPoint!);
      await _loadRoute();
    } catch (e) {
      _logger.error('fetchCurrentLocation failed', error: e);
      _error = SafeErrorMessages.generic;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(String requestId) async {
    try {
      final coords = await _geolocation.getCoordinates(requestId);
      _currentPoint = GeoPoint(coords.origin[0], coords.origin[1]);
      _destinationPoint =
          GeoPoint(coords.destination[0], coords.destination[1]);
      _currentAddress = await _getAddress(_currentPoint!);
      _destinationAddress = await _getAddress(_destinationPoint!);
      await _loadRoute();
    } catch (e) {
      _logger.error('updateLocation failed', error: e);
      _error = SafeErrorMessages.generic;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDestination(String requestId) async {
    try {
      final coords = await _geolocation.getCoordinates(requestId);
      _destinationPoint =
          GeoPoint(coords.destination[0], coords.destination[1]);
      _destinationAddress = await _getAddress(_destinationPoint!);
      await _loadRoute();
      notifyListeners();
    } on Exception catch (e) {
      _logger.error('setDestination failed', error: e);
      _error = SafeErrorMessages.generic;
      notifyListeners();
    }
  }

  void clearDestination() {
    _destinationPoint = null;
    _destinationAddress = '';
    _routePoints = const [];
    notifyListeners();
  }

  Future<void> _loadRoute() async {
    if (_routing == null ||
        _currentPoint == null ||
        _destinationPoint == null) {
      _routePoints = [
        if (_currentPoint != null) _currentPoint!,
        if (_destinationPoint != null) _destinationPoint!,
      ];
      return;
    }

    try {
      final result = await _routing.route(_currentPoint!, _destinationPoint!);
      _routePoints = result.points;
    } catch (e) {
      _logger.error('OSRM route failed — fallback straight line', error: e);
      _routePoints = [_currentPoint!, _destinationPoint!];
    }
  }

  Future<String> _getAddress(GeoPoint point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return 'Local desconhecido';
      final p = placemarks.first;
      final partes = <String>[];
      if (p.street?.isNotEmpty == true) partes.add(p.street!);
      if (p.subLocality?.isNotEmpty == true) partes.add(p.subLocality!);
      if (p.locality?.isNotEmpty == true) partes.add(p.locality!);
      if (p.administrativeArea?.isNotEmpty == true) {
        partes.add(p.administrativeArea!);
      }
      return partes.isNotEmpty ? partes.join(', ') : 'Local desconhecido';
    } catch (_) {
      return '${point.latitude.toStringAsFixed(4)}, '
          '${point.longitude.toStringAsFixed(4)}';
    }
  }
}
