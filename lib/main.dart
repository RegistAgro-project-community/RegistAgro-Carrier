import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/auth/otpscreen/otp_screnn.dart';
import 'package:registagrodriver/auth/signup/sign_up.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/Onboarding_screen/onboarding_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();
  final lastRoute = prefs.getString("last_route") ?? "/";
  
  runApp(TISApp(initialRoute: lastRoute));
}

class TISApp extends StatelessWidget {
  final String initialRoute;
  const TISApp({super.key, required this.initialRoute});

  Future<void> _saveRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("last_route", route);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIS - Transport Information System',
      theme: REGISTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        _saveRoute(settings.name ?? "/");
        return MaterialPageRoute(
          builder: (context) => _getPage(settings.name),
        );
      },
    );
  }

  Widget _getPage(String? route) {
    switch (route) {
      case "/Login":
        return const Login();
      case "/MainPage":
        return const MainNavScreen();
      case "/Signup":
        return const SignUp();
      case '/otpCode':
        return const OtpScreen();
      default:
        return const OnboardingScreen();
    }
  }
}
