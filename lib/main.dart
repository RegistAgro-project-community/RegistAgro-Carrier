import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/auth/otpscreen/otp_screnn.dart';
import 'package:registagrodriver/auth/signup/sign_up.dart';
import 'package:registagrodriver/providers/location_provider.dart';
import 'package:registagrodriver/repositories/auth/login.dart';
import 'package:registagrodriver/repositories/geolocation.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/transportRequest.dart';
import 'package:registagrodriver/repositories/vehicle.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:registagrodriver/screens/Onboarding_screen/onboarding_screen.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/services/geocoding_service.dart';
import 'package:registagrodriver/services/routing/osrm_routing_service.dart';
import 'package:registagrodriver/services/routing/routing_service.dart';
import 'package:registagrodriver/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await DioClient().init();

  final prefs = await SharedPreferences.getInstance();
  final lastRoute = prefs.getString('last_route') ?? '/';

  runApp(TISApp(initialRoute: lastRoute));
}

class TISApp extends StatelessWidget {
  final String initialRoute;
  const TISApp({super.key, required this.initialRoute});

  Future<void> _saveRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', route);
  }

  @override
  Widget build(BuildContext context) {
    // DIP: inject abstractions via Provider
    return MultiProvider(
      providers: [
        Provider<IAuthRepository>(create: (_) => AuthRepository()),
        Provider<ITransportRepository>(create: (_) => TransportRequest()),
        Provider<IVehicleRepository>(create: (_) => VehicleRepositorie()),
        Provider<IProfileRepository>(create: (_) => Profile()),
        Provider<IGeolocationRepository>(create: (_) => GeoLocation()),
        Provider<RoutingService>(create: (_) => OsrmRoutingService()),
        Provider<GeocodingService>(create: (_) => GeocodingService()),
        ChangeNotifierProvider(
          create: (ctx) => SourceLocationProvider(
            geolocation: ctx.read<IGeolocationRepository>(),
            routing: ctx.read<RoutingService>(),
            geocoder: ctx.read<GeocodingService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RegistAgro - Transport Information System',
        theme: REGISTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(),
        initialRoute: initialRoute,
        onGenerateRoute: (settings) {
          _saveRoute(settings.name ?? '/');
          return MaterialPageRoute(
            builder: (context) => _getPage(settings.name),
          );
        },
      ),
    );
  }

  Widget _getPage(String? route) {
    switch (route) {
      case '/Login':
        return const Login();
      case '/MainPage':
        return const MainNavScreen();
      case '/Signup':
        return const SignUp();
      case '/otpCode':
        return const OtpScreen();
      default:
        return const OnboardingScreen();
    }
  }
}
