import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:registagrodriver/components/google_maps/location_provider.dart';
import 'theme/app_theme.dart';
import 'screens/Onboarding_screen/onboarding_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SourceLocationProvider()),
      ],
      child: MaterialApp(
        title: 'RegistAgro - Transport Information System',
        theme: REGISTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(),
      ),
    );
  }
}