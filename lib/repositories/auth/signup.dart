import 'package:dio/dio.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/otpscreen/otp_screnn.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio(
  BaseOptions(
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ),
);

class SignupValidations {
  String? name;
  String? phone;
  String? email;
  String? province;
  String? adress;
  String? pass1;
  String? pass2;

  SignupValidations({
    this.name,
    this.email,
    this.phone,
    this.province,
    this.adress,
    this.pass1,
    this.pass2,
  });

  sendEmail(BuildContext context) async {
    final userData = {
      "name": name,
      "email": email,
      "phone": phone,
      "adress": adress,
      "province": province,
      "pass1": pass1,
      "pass2": pass2,
    };

    try {
      final res = await dio.post(
        'https://api-registagro.onrender.com/auth/signup/carrier',
        data: userData,
      );

      ElegantNotification.info(
        title: Text("Enviando código"),
        description: Text(res.data['message']),
        height: 80,
        // ignore: use_build_context_synchronously
      ).show(context);

      final prefes = await SharedPreferences.getInstance();
      prefes.setString("last_route", '/otpCode');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['error'] is List) {
        final List errors = data['error'];

        if (errors.isNotEmpty && errors.first is String) {
          final message = errors.join('\n');

          ElegantNotification.error(
            title: const Text("Error"),
            description: Text(message),
            height: 120,
            // ignore: use_build_context_synchronously
          ).show(context);
        } else {
          for (final err in errors) {
            final message = err['message'];

            ElegantNotification.error(
              title: Text("Error"),
              description: Text(message),
              height: 80,
              // ignore: use_build_context_synchronously
            ).show(context);

            await Future.delayed(const Duration(seconds: 5));
          }
        }
      } else {
        ElegantNotification.error(
          title: const Text("Error"),
          description: Text(
            e.response?.data['message'] ?? e.response?.data["error"],
          ),
          height: 80,
          // ignore: use_build_context_synchronously
        ).show(context);
      }
    }
  }

  validateOtp(BuildContext context, String code) async {
    try {
      final otpCode = await dio.get(
        'https://api-registagro.onrender.com/auth/signup/verify/$code',
      );

      final authHeader = otpCode.headers.value('authorization');
      final token = authHeader?.split(" ")[1];

      final tokenStorage = TokenStorage();

      try {
        await tokenStorage.storeToken(token!);

        final message = otpCode.data['message'];

        ElegantNotification.success(
          title: Text("Sucess"),
          description: Text(message),
          height: 80,
          // ignore: use_build_context_synchronously
        ).show(context);

        final prefes = await SharedPreferences.getInstance();
        prefes.setString("last_route", '/MainPage');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainNavScreen()),
          (route) => false,
        );
      } catch (e) {
        ElegantNotification.error(
          title: Text("Error"),
          description: Text('Ocorreu um erro inesperado'),
          height: 80,
          // ignore: use_build_context_synchronously
        ).show(context);
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.response?.data?['error'];

      ElegantNotification.error(
        title: Text("Error"),
        description: Text(message),
        height: 80,
        // ignore: use_build_context_synchronously
      ).show(context);
    }
  }
}
