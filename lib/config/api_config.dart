/// Centralized API configuration via `--dart-define`.
///
/// Build example:
/// ```bash
/// flutter build apk \
///   --dart-define=API_BASE_URL=http://192.168.18.7:5500 \
///   --dart-define=TURNSTILE_SITE_KEY=your_site_key
/// ```
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.18.7:80',
  );

  static const String turnstileSiteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '',
  );

  /// OSRM public demo server (same as Web). Override via --dart-define.
  static const String osrmBaseUrl = String.fromEnvironment(
    'OSRM_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  // Auth
  static const String carrierLogin = '/auth/login/carrier';
  static const String carrierSignup = '/auth/signup/carrier';
  static String verifyOtp(String code) => '/auth/signup/verify/$code';

  // Transport
  static const String carrierRequests = '/transports/carrier/request/get';
  static const String carrierAccept = '/transports/carrier/request/accept';
  static String carrierFinish(String requestId) =>
      '/flow/carrier/finish/request/$requestId';
  static const String carrierVehicles = '/transports/carriers/vehicles';
  static const String vehicleCreate = '/transports/vehicle/create';

  // Profile / location
  static const String userProfile = '/users/profile';
  static String carrierDirection(String requestId) =>
      '/location/carrier/direction/request/$requestId';
}
