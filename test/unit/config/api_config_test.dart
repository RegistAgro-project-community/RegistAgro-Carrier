import 'package:flutter_test/flutter_test.dart';
import 'package:registagrodriver/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('baseUrl tem default de desenvolvimento (192.168.18.7)', () {
      expect(ApiConfig.baseUrl, contains('192.168.18.7'));
    });

    test('endpoints constroem paths relativos correctos', () {
      expect(ApiConfig.carrierLogin, '/auth/login/carrier');
      expect(ApiConfig.carrierSignup, '/auth/signup/carrier');
      expect(ApiConfig.carrierRequests, '/transports/carrier/request/get');
      expect(ApiConfig.carrierAccept, '/transports/carrier/request/accept');
      expect(
        ApiConfig.carrierFinish('abc'),
        '/flow/carrier/finish/request/abc',
      );
      expect(ApiConfig.verifyOtp('123456'), '/auth/signup/verify/123456');
      expect(ApiConfig.userProfile, '/users/profile');
      expect(
        ApiConfig.carrierDirection('req-1'),
        '/location/carrier/direction/request/req-1',
      );
    });
  });
}
