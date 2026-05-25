import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/auth/login/login.dart';
import 'package:registagrodriver/components/topNotification/top_notification.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/screens/Onboarding_screen/onboarding_screen.dart';
import 'package:registagrodriver/screens/profile/profile_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  logout(BuildContext context) async {
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
            ));
        },
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      showTopNotification(
        context,
        title: "Sucess",
        description: "Sessão terminada com sucesso",
        backgroundColor: Colors.green,
        icon: Icons.verified,
      );

      final prefes = await SharedPreferences.getInstance();
      prefes.setString("last_route", '/');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
        (route) => false,
      );
    } else {
      showTopNotification(
        context,
        title: "Error",
        description: "Não foi possível fazer terminar sessão",
        backgroundColor: Colors.amber,
        icon: Icons.error_outline,
      );
    }
  }

  Future<UserModel> userData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,           
        )),
    );

    try {
      final tokenMap = await TokenStorage().readToken();

      if (tokenMap.containsKey("error") || tokenMap["token"] == null) {
        handleAuthError(
          context,
          tokenMap['error'] ?? "Faça login novamente",
        );

        throw Exception("Error");
      }

      final dio = Dio(
        BaseOptions(
          headers: {
            "content-type": "application/json",
            "authorization": "Bearer ${tokenMap["token"]}",
          },
        ),
      );

      final res = await dio.get(
        "https://api-registagro.onrender.com/users/profile",
      );

      Navigator.of(context).pop();

      final data = res.data["data"];

      return UserModel(
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        bio: "bio",
        province: data['province'],
        adress: data['adress'],
        profile: data['profile'],
        balance: res.data["balance"]
      );
    } on DioException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      String message = "Erro ao carregar produtos";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = e.response?.data?['error'] ?? 'Sessão expirada';

        handleAuthError(context, message);
      } else {
        message =
            e.response?.data?['error'] ??
            e.response?.data?['info'] ??
            e.message ??
            message;

        showTopNotification(
          context,
          title: "Error",
          description: message,
          backgroundColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
      }

      throw Exception(message);
    } catch (e) {
      Navigator.of(context).pop();

      handleAuthError(
        context,
        "Ocorreu um erro inesperado",
      );

      throw Exception("Error");
    }
  }

  void handleAuthError(BuildContext context, String message) {
    showTopNotification(
      context,
      title: "Error",
      description: message,
      backgroundColor: Colors.amber,
      icon: Icons.error_outline,
    );

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("last_route", '/');
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }
}
