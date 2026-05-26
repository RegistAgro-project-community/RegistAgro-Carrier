import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/signup/sign_up.dart';
import 'package:registagrodriver/components/showModalBottomSheetAdmin/modal_bottomsheet_admin.dart';
import 'package:registagrodriver/repositories/auth/login.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:registagrodriver/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final res = await login(context, email, password);

    if (!mounted) return;
    setState(() => isLoading = false);
    
    if (res.containsKey('message')) {
      ElegantNotification.success(
        title: Text("${res['message']}"),
        description: const Text(
          "Seja bem-vindo de volta!",
          style: TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        icon: const SizedBox(),
        height: 75,
        // ignore: use_build_context_synchronously
        width: MediaQuery.of(context).size.width * .9,
        animation: AnimationType.fromTop,
        // ignore: use_build_context_synchronously
      ).show(context);

      final prefes = await SharedPreferences.getInstance();
      prefes.setString("last_route", '/MainPage');

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => MainNavScreen()),
        (route) => false,
      );
    } else {
      ElegantNotification.error(
        title: Text("Error"),
        description: Text(
          "${res['error']}",
          style: TextStyle(fontFamily: 'Inter', color: Colors.grey),
        ),
        icon: const SizedBox(),
        height: 75,
        // ignore: use_build_context_synchronously
        width: MediaQuery.of(context).size.width * .9,
        animation: AnimationType.fromTop,
        // ignore: use_build_context_synchronously
      ).show(context);
      
    }
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
                    prefixIcon: Icon(Icons.email_outlined, color: REGISTheme.textSecondary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o seu email';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                      return 'Por favor, insira a sua palavra-passe';
                    }
                    if (value.length < 6) {
                      return 'A palavra-passe deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
                        MaterialPageRoute(builder: (context) => SignUp()),
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
                      style: TextStyle(color: REGISTheme.textSecondary, fontSize: 13),
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