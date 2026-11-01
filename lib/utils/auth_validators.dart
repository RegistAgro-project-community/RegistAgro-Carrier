/// Client-side UX validators. Backend Zod remains the source of truth.
class AuthValidators {
  AuthValidators._();

  static final _emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _otpRegex = RegExp(r'^\d{6}$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email obrigatório';
    if (!_emailRegex.hasMatch(value.trim())) return 'Email inválido';
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < minLength) return 'Mínimo $minLength caracteres';
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'Código obrigatório';
    if (value.length != 6) return 'Código deve ter 6 dígitos';
    if (!_otpRegex.hasMatch(value)) return 'Apenas números';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome obrigatório';
    }
    if (value.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Insira o nome e o apelido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Número inválido (mínimo 9 dígitos)';
    return null;
  }

  static String? validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label obrigatório';
    return null;
  }
}
