import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/components/safe_notification.dart';
import 'package:registagrodriver/components/turnstile_widget.dart';
import 'package:registagrodriver/repositories/auth/signup.dart';
import 'package:registagrodriver/services/geocoding_service.dart';
import 'package:registagrodriver/theme/app_theme.dart';
import 'package:registagrodriver/utils/auth_validators.dart';
import 'package:registagrodriver/utils/safe_error.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _turnstileKey = GlobalKey<TurnstileWidgetState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _province = TextEditingController();
  final _location = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String? _turnstileToken;
  final _geocoder = GeocodingService();

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_turnstileToken == null || _turnstileToken!.isEmpty) {
      showSafeNotification(
        context,
        title: 'Verificação',
        description: SafeErrorMessages.captchaFailed,
        backgroundColor: Colors.amber.shade700,
        icon: Icons.security,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // SSRF protection: validate address is within Angola before signup
      await _geocoder.geocodeAddress(
        '${_location.text}, ${_province.text}, Angola',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showSafeNotification(
        context,
        title: 'Localização',
        description: 'Endereço fora da área de operação (Angola)',
        backgroundColor: Colors.amber.shade700,
        icon: Icons.location_off,
      );
      return;
    }

    final signupClass = SignupValidations(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      province: _province.text,
      adress: _location.text,
      pass1: _passwordController.text,
      pass2: _passwordConfirmController.text,
      captchaToken: _turnstileToken,
    );

    await signupClass.sendEmail(context);

    if (!mounted) return;
    setState(() {
      isLoading = false;
      _turnstileToken = null;
    });
  }

  @override
  void dispose() {
    _province.dispose();
    _location.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    color: REGISTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha os dados para se registar!',
                  style: TextStyle(color: REGISTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: Icon(Icons.person_outline, color: REGISTheme.textSecondary),
                      ),
                      validator: AuthValidators.validateName,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone_outlined, color: REGISTheme.textSecondary),
                      ),
                      validator: AuthValidators.validatePhone,
                    ),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: REGISTheme.textSecondary),
                      ),
                      validator: AuthValidators.validateEmail,
                    ),
                    TextFormField(
                      controller: _location,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Localização',
                        prefixIcon: Icon(Icons.location_on, color: REGISTheme.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira a sua localização';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _province,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Província',
                        prefixIcon: Icon(Icons.location_city, color: REGISTheme.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira a sua província';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Palavra-passe',
                        prefixIcon: const Icon(Icons.lock_outline, color: REGISTheme.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: REGISTheme.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma palavra-passe';
                        }
                        if (value.length < 6) {
                          return 'A palavra-passe deve ter pelo menos 6 caracteres';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Deve conter pelo menos uma letra maiúscula';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Deve conter pelo menos um número';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordConfirmController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar palavra-passe',
                        prefixIcon: const Icon(Icons.lock_outline, color: REGISTheme.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: REGISTheme.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme a sua palavra-passe';
                        }
                        if (value != _passwordController.text) {
                          return 'As palavras-passe não coincidem';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TurnstileWidget(
                                  key: _turnstileKey,
                                  action: 'signup',
                                  onVerify: (token) => setState(() => _turnstileToken = token),
                                  onTokenExpired: () => setState(() => _turnstileToken = null),
                                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Criar Conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem conta? ',
                      style: TextStyle(color: REGISTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: REGISTheme.accentLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}