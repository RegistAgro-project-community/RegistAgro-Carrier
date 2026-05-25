import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/components/topNotification/top_notification.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/storage.dart';

class VehicleRepositorie {
  Future<List<Vehicle>> getVehicle(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );

    try {
      final tokenMap = await TokenStorage().readToken();

      if (tokenMap.containsKey("error") || tokenMap["token"] == null) {
        Profile().handleAuthError(
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
        "https://api-registagro.onrender.com/transports/carriers/vehicles",
      );

      Navigator.of(context).pop();

      final json = res.data as Map<String, dynamic>? ?? {};
      final List<dynamic> items = json["vehicles"] as List<dynamic>? ?? [];

      return items
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      String message = "Erro ao carregar produtos";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = e.response?.data?['error'] ?? 'Sessão expirada';

        Profile().handleAuthError(context, message);
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

      Profile().handleAuthError(context, "Ocorreu um erro inesperado");

      throw Exception("Error");
    }
  }
}
