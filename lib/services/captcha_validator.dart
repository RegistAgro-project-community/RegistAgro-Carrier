/// CAPTCHA token holder — OCP/LSP (mockable in tests).
abstract class CaptchaValidator {
  String? get token;
  bool get isVerified;
  void onVerify(String token);
  void clear();
}

class TurnstileCaptchaValidator implements CaptchaValidator {
  String? _token;

  @override
  String? get token => _token;

  @override
  bool get isVerified => _token != null && _token!.isNotEmpty;

  @override
  void onVerify(String token) {
    _token = token.isEmpty ? null : token;
  }

  @override
  void clear() => _token = null;
}
