import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/auth/signup/sign_up.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.directions_car_rounded,
      title: 'Bem-vindo ao RegistAgro - Trans',
      subtitle:
          'Conectamos passageiros e motoristas\nde forma rápida e segura em Angola.',
    ),
    _OnboardingPage(
      icon: Icons.local_shipping_rounded,
      title: 'Transporte de Carga',
      subtitle: 'Envie e receba mercadorias com\nrastreamento em tempo real.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      title: 'Motoristas Verificados',
      subtitle:
          'Todos os motoristas passam por\nprocesso rigoroso de verificação.',
    ),
    _OnboardingPage(
      icon: Icons.local_shipping_rounded,
      title: 'Transporte de Carga',
      subtitle: 'Envie e receba mercadorias com\nrastreamento em tempo real.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      title: 'Motoristas Verificados',
      subtitle:
          'Todos os motoristas passam por\nprocesso rigoroso de verificação.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 150),
            const SizedBox(height: 8),
            const SizedBox(height: 40),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i].build(context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? REGISTheme.accent
                        : REGISTheme.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Login(),
                      ),
                    ),
                    child: const Text('Começar Agora'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    spacing: 1,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Não tenho conta!"),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUp(),
                          ),
                        ),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: REGISTheme.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: REGISTheme.accent.withOpacity(0.1),
              border: Border.all(
                color: REGISTheme.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 56, color: REGISTheme.accentLight),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              color: REGISTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: REGISTheme.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
