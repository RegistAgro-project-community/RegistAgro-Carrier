import 'package:flutter_test/flutter_test.dart';
import 'package:registagrodriver/services/geocoding_service.dart';

void main() {
  group('GeocodingService', () {
    test('coordenadas Angola → true', () {
      expect(GeocodingService.validateAngolaBounds(-8.8, 13.2), isTrue); // Luanda
      expect(GeocodingService.validateAngolaBounds(-12.5, 15.0), isTrue);
    });

    test('coordenadas fora Angola → false', () {
      expect(GeocodingService.validateAngolaBounds(40.7, -74.0), isFalse); // NYC
      expect(GeocodingService.validateAngolaBounds(0, 0), isFalse);
      expect(GeocodingService.validateAngolaBounds(-20, 13), isFalse);
    });

    test('limites da bounding box', () {
      expect(GeocodingService.validateAngolaBounds(-18, 11), isTrue);
      expect(GeocodingService.validateAngolaBounds(-4, 24), isTrue);
      expect(GeocodingService.validateAngolaBounds(-18.1, 11), isFalse);
      expect(GeocodingService.validateAngolaBounds(-4, 24.1), isFalse);
    });

    test('geocodeAddress endereço vazio → throws', () async {
      final service = GeocodingService();
      expect(
        () => service.geocodeAddress(''),
        throwsA(isA<Exception>()),
      );
      expect(
        () => service.geocodeAddress('   '),
        throwsA(isA<Exception>()),
      );
    });
  });
}
