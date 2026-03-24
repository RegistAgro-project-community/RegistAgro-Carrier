import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/screens/main_nav_screen.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
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

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira o seu nome completo';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'Insira o nome e o apelido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: REGISTheme.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone_outlined, color: REGISTheme.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira o seu número de telefone';
                        }
                        if (value.length < 9) {
                          return 'Número de telefone inválido (mínimo 9 dígitos)';
                        }
                        return null;
                      },
                    ),
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
                const SizedBox(height: 32),
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