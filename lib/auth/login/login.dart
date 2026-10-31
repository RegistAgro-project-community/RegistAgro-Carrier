import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/signup/sign_up.dart';
import 'package:registagrodriver/components/safe_notification.dart';
import 'package:registagrodriver/components/showModalBottomSheetAdmin/modal_bottomsheet_admin.dart';
import 'package:registagrodriver/components/turnstile_widget.dart';
import 'package:registagrodriver/repositories/auth/login.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:registagrodriver/services/auth_rate_limiter.dart';
import 'package:registagrodriver/theme/app_theme.dart';
import 'package:registagrodriver/utils/auth_validators.dart';
import 'package:registagrodriver/utils/safe_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _turnstileKey = GlobalKey<TurnstileWidgetState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rateLimiter = AuthRateLimiter();
  String? _turnstileToken;

  Future<void> _submit() async {
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

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final canTry = await _rateLimiter.canAttempt(email);
    if (!canTry) {
      final mins = await _rateLimiter.getRemainingMinutes(email);
      if (!mounted) return;
      showSafeNotification(
        context,
        title: 'Bloqueado',
        description: 'Muitas tentativas. Tente em ${mins ?? 15} min.',
        backgroundColor: Colors.amber.shade700,
        icon: Icons.lock_clock,
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await login(
      context,
      email,
      password,
      captchaToken: _turnstileToken,
    );

    final success = res.containsKey('message');
    await _rateLimiter.recordAttempt(email, success);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      ElegantNotification.success(
        title: Text('${res['message']}'),
        description: const Text(
          'Seja bem-vindo de volta!',
          style: TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        icon: const SizedBox(),
        height: 75,
        width: MediaQuery.of(context).size.width * .9,
        animation: AnimationType.fromTop,
      ).show(context);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', '/MainPage');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
        (route) => false,
      );
    } else {
          showSafeNotification(
            context,
            title: 'Erro',
            description: res['error'] ?? SafeErrorMessages.credentialsInvalid,
          );
          setState(() => _turnstileToken = null);
          await _turnstileKey.currentState?.reset();
        }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 32),
                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    color: REGISTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre com as suas credenciais \n e inicie uma corrida!',
                  style: TextStyle(color: REGISTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: REGISTheme.textPrimary),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: REGISTheme.textSecondary,
                    ),
                  ),
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: REGISTheme.textPrimary),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Palavra-passe',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: REGISTheme.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: REGISTheme.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      AuthValidators.validatePassword(v, minLength: 6),
                ),
                const SizedBox(height: 16),
                TurnstileWidget(
                                  key: _turnstileKey,
                                  action: 'login',
                                  onVerify: (token) => setState(() => _turnstileToken = token),
                                  onTokenExpired: () => setState(() => _turnstileToken = null),
                                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Entrar'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: REGISTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      ),
                      child: const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: REGISTheme.accentLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: TextButton(
                    onPressed: () => showContactAdmin(context),
                    child: const Text(
                      'Contactar Administrador',
                      style: TextStyle(
                        color: REGISTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
