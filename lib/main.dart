import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TISApp());
}

class TISApp extends StatelessWidget {
  const TISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIS - Transport Information System',
      theme: REGISTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
