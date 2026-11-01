import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/components/safe_notification.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/screens/Onboarding_screen/onboarding_screen.dart';
import 'package:registagrodriver/screens/profile/profile_class.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/utils/safe_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile implements IProfileRepository {
  Future<void> logout(BuildContext context) async {
    final tokenClass = TokenStorage();
    final logoutResult = await tokenClass.logout();

    if (logoutResult.containsKey('message')) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!context.mounted) return;
      Navigator.of(context).pop();
      showSafeNotification(
        context,
        title: 'Sucesso',
        description: 'Sessão terminada com sucesso',
        backgroundColor: Colors.green,
        icon: Icons.verified,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', '/');

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } else if (context.mounted) {
      showSafeNotification(
        context,
        title: 'Erro',
        description: 'Não foi possível terminar sessão',
        backgroundColor: Colors.amber,
        icon: Icons.error_outline,
      );
    }
  }

  Future<UserModel> userData(
    BuildContext context, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    try {
      final tokenMap = await TokenStorage().readToken();

      if (tokenMap.containsKey('error') || tokenMap['token'] == null) {
        handleAuthError(
          context,
          tokenMap['error'] ?? SafeErrorMessages.sessionExpired,
        );
        throw Exception('Error');
      }

      final dio = DioClient().dio;
      final res = await dio.get(ApiConfig.userProfile);

      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      final data = res.data['data'];
      final userId = data['id']?.toString() ?? data['userId']?.toString();
      if (userId != null && userId.isNotEmpty) {
        await TokenStorage().storeCarrierId(userId);
      }

      return UserModel(
              id: userId,
              name: data['name'] as String?,
              email: data['email'] as String?,
              phone: data['phone'] as String?,
              bio: data['bio'] as String? ?? '',
              province: data['province'] as String?,
              adress: data['adress'] as String?,
              profile: data['profile'] as String?,
              balance: res.data['balance']?.toString() ?? '0',
            );
    } on DioException catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      final message = SafeErrorMessages.fromDio(e);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        handleAuthError(context, SafeErrorMessages.sessionExpired);
      } else if (context.mounted) {
        showSafeNotification(
          context,
          title: 'Erro',
          description: message,
        );
      }

      throw Exception(message);
    } catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      handleAuthError(context, SafeErrorMessages.generic);
      throw Exception('Error');
    }
  }

  void handleAuthError(BuildContext context, String message) {
    showSafeNotification(
      context,
      title: 'Erro',
      description: SafeErrorMessages.sanitize(message),
      backgroundColor: Colors.amber,
      icon: Icons.error_outline,
    );

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_route', '/');
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }
}
