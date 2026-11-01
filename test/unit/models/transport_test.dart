import 'package:flutter_test/flutter_test.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';

Transport _transport({
  required String status,
  String carrierId = '',
}) {
  return Transport(
    id: 'req-1',
    carrierId: carrierId,
    status: status,
    delivered_at: null,
    start_at: null,
    farm: Farm(
      id: 'f1',
      name: 'Farm',
      phone: '',
      province: '',
      adress: '',
      profile: '',
    ),
    order: Order(
      productId: 'p1',
      productName: 'Tomate',
      price: '100',
      photo: '',
      qtd: '10',
      earning: '50',
      delivery_adress: 'Luanda',
    ),
    vehicle: Vehicle(
      id: 'v1',
      brand: 'Toyota',
      plate: 'LD-00-00',
      type: 'fechado',
      capacity: '1000',
      photo: '',
    ),
  );
}

void main() {
  group('Transport.canAccept/canFinish', () {
    test('status=pendente + sem carrierId → canAccept=true', () {
      final t = _transport(status: 'pendente');
      expect(t.canAccept('carrier-A'), isTrue);
    });

    test('status=pendente + carrierId=owner → canAccept=true', () {
      final t = _transport(status: 'pendente', carrierId: 'carrier-A');
      expect(t.canAccept('carrier-A'), isTrue);
    });

    test('status=pendente + carrierId≠owner → canAccept=false', () {
      final t = _transport(status: 'pendente', carrierId: 'carrier-B');
      expect(t.canAccept('carrier-A'), isFalse);
    });

    test('status=em_transporte + carrierId=owner → canFinish=true', () {
      final t = _transport(status: 'em_transporte', carrierId: 'carrier-A');
      expect(t.canFinish('carrier-A'), isTrue);
      expect(t.canAccept('carrier-A'), isFalse);
    });

    test('status=em_transporte + carrierId≠owner → canFinish=false', () {
      final t = _transport(status: 'em_transporte', carrierId: 'carrier-B');
      expect(t.canFinish('carrier-A'), isFalse);
    });

    test('status=entregue → sem acções', () {
      final t = _transport(status: 'entregue', carrierId: 'carrier-A');
      expect(t.canAccept('carrier-A'), isFalse);
      expect(t.canFinish('carrier-A'), isFalse);
    });
  });
}
