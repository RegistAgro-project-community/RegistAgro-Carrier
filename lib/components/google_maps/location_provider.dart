import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:registagrodriver/models/direction_model.dart';
import 'package:registagrodriver/repositories/geolocation.dart';

class SourceLocationProvider extends ChangeNotifier {
  gmaps.LatLng? _currentLatLng;
  gmaps.LatLng? _destinationLatLng;
  String _currentAddress = '';
  String _destinationAddress = '';
  bool _isLoading = false;
  String? _error;

  gmaps.LatLng? get currentLatLng => _currentLatLng;
  gmaps.LatLng? get destinationLatLng => _destinationLatLng;
  String get currentAddress => _currentAddress;
  String get destinationAddress => _destinationAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentLocation(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      /*bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'GPS desativado. Ative a localização.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = 'Permissão de localização negada';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );*/

      final DirectionModel coordinates = await GeoLocation().carrierCoordinates(
        requestId,
      );

      _currentLatLng = gmaps.LatLng(
        coordinates.origin[0],
        coordinates.origin[1],
      );
      
      _destinationLatLng = gmaps.LatLng(
        coordinates.destination[0],
        coordinates.destination[1],
      );

      _currentAddress = await _getAddress(_currentLatLng!);

      _destinationAddress = await _getAddress(_destinationLatLng!);
    } catch (e) {
      _error = 'Não foi possível obter localização';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(String requestId) async {
    try {

      final DirectionModel coordinates = await GeoLocation().carrierCoordinates(
        requestId,
      );

      _currentLatLng = gmaps.LatLng(
        coordinates.origin[0],
        coordinates.origin[1],
      );
      
      _destinationLatLng = gmaps.LatLng(
        coordinates.destination[0],
        coordinates.destination[1],
      );

      _currentAddress = await _getAddress(_currentLatLng!);

      _destinationAddress = await _getAddress(_destinationLatLng!);
    } catch (e) {
      _error = 'Não foi possível obter localização';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDestination(String requestId) async {
    try {
      final DirectionModel coordinates = await GeoLocation().carrierCoordinates(
        requestId,
      );

      _destinationLatLng = gmaps.LatLng(
        coordinates.destination[0],
        coordinates.destination[1],
      );

      _destinationAddress = await _getAddress(_currentLatLng!);

      notifyListeners();
    } on Exception catch (_) {
      _error = "Não foi possível obter localização";
    }
  }

  void clearDestination() {
    _destinationLatLng = null;
    _destinationAddress = '';
    notifyListeners();
  }

  Future<String> _getAddress(gmaps.LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return 'Local desconhecido';
      final p = placemarks.first;
      final partes = <String>[];
      if (p.street?.isNotEmpty == true) partes.add(p.street!);
      if (p.subLocality?.isNotEmpty == true) partes.add(p.subLocality!);
      if (p.locality?.isNotEmpty == true) partes.add(p.locality!);
      if (p.administrativeArea?.isNotEmpty == true)
        partes.add(p.administrativeArea!);
      return partes.isNotEmpty ? partes.join(', ') : 'Local desconhecido';
    } catch (_) {
      // ignore: avoid_catches_without_on_clauses
      return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
    }
  }
}
