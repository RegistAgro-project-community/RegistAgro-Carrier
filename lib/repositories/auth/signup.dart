import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/otpscreen/otp_screnn.dart';
import 'package:registagrodriver/components/safe_notification.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/utils/safe_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupValidations {
  String? name;
  String? phone;
  String? email;
  String? province;
  String? adress;
  String? pass1;
  String? pass2;
  String? captchaToken;

  SignupValidations({
    this.name,
    this.email,
    this.phone,
    this.province,
    this.adress,
    this.pass1,
    this.pass2,
    this.captchaToken,
  });

  Future<void> sendEmail(BuildContext context) async {
    final userData = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'adress': adress,
      'province': province,
      'pass1': pass1,
      'pass2': pass2,
    };
    if (captchaToken != null && captchaToken!.isNotEmpty) {
      userData['captchaToken'] = captchaToken;
    }

    try {
      final dio = DioClient().dio;
      final res = await dio.post(ApiConfig.carrierSignup, data: userData);

      final message = SafeErrorMessages.sanitize(
        res.data['message']?.toString() ?? 'Código enviado',
      );

      if (!context.mounted) return;
      showSafeNotification(
        context,
        title: 'Enviando código',
        description: message,
        backgroundColor: Colors.blue.shade700,
        icon: Icons.info_outline,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', '/otpCode');

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OtpScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      showSafeNotification(
        context,
        title: 'Erro',
        description: SafeErrorMessages.fromDio(e),
      );
    }
  }

  Future<void> validateOtp(BuildContext context, String code) async {
    try {
      final dio = DioClient().dio;
      final otpCode = await dio.get(ApiConfig.verifyOtp(code));

      final authHeader = otpCode.headers.value('authorization');
      final token = authHeader?.split(' ').last;

      if (token == null || token.isEmpty) {
        if (!context.mounted) return;
        showSafeNotification(
          context,
          title: 'Erro',
          description: SafeErrorMessages.generic,
        );
        return;
      }

      final tokenStorage = TokenStorage();
      await tokenStorage.storeToken(token);

      final userId = otpCode.data is Map
          ? otpCode.data['userId'] ?? otpCode.data['id']
          : null;
      if (userId is String && userId.isNotEmpty) {
        await tokenStorage.storeCarrierId(userId);
      }

      final message = SafeErrorMessages.sanitize(
        otpCode.data['message']?.toString() ?? 'Conta verificada',
      );

      if (!context.mounted) return;
      showSafeNotification(
        context,
        title: 'Sucesso',
        description: message,
        backgroundColor: Colors.green.shade700,
        icon: Icons.verified,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', '/MainPage');

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      showSafeNotification(
        context,
        title: 'Erro',
        description: SafeErrorMessages.fromDio(e),
      );
    }
  }
}
