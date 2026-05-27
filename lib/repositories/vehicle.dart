import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/components/topNotification/top_notification.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/storage.dart';

class VehicleRepositorie {
  Future<List<Vehicle>> getVehicle(
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

      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      final json = res.data as Map<String, dynamic>? ?? {};
      final List<dynamic> items = json["vehicles"] as List<dynamic>? ?? [];

      return items
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      String message = "Erro ao carregar veículos";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = e.response?.data?['error'] ?? 'Sessão expirada';

        Profile().handleAuthError(context, message);
      } else {
        message =
            e.response?.data?['error'] ??
            e.response?.data?['info'] ??
            e.message ??
            message;

        e.response?.data["error"] != null || e.response?.data["info"] != null ? 
        showTopNotification(
          context,
          title: "Error",
          description: message,
          backgroundColor: Colors.red.shade700,
          icon: Icons.error_outline,
        ) :

        print(message);
      }

      print(message);
      rethrow;
    } catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      Profile().handleAuthError(context, "Ocorreu um erro inesperado");

      throw Exception("Error");
    }
  }

  Future<String> createVehicle(
    BuildContext context,
    String brand,
    String plate,
    String category,
    int capacity,
    String unit,
    File img,
  ) async {
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
        BaseOptions(headers: {"authorization": "Bearer ${tokenMap["token"]}"}),
      );

      final ext = img.path.split('.').last.toLowerCase();

      final contentType = switch (ext) {
        'png' => DioMediaType('image', 'png'),
        'webp' => DioMediaType('image', 'webp'),
        'jpg' => DioMediaType('image', 'jpg'),
        _ => DioMediaType('image', 'jpeg'),
      };

      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
          contentType: contentType,
        ),
        "brand": brand,
        "plate": plate,
        "category": category,
        "capacity": capacity,
        "unit": unit,
      });

      final res = await dio.post(
        "https://api-registagro.onrender.com/transports/vehicle/create",
        data: formData,
      );

      Navigator.of(context).pop();

      final json = res.data as Map<String, dynamic>? ?? {};
      final String message = json["message"] as String? ?? "";

      return message;
    } on DioException catch (e) {
      Navigator.of(context).pop();

      String message = "Erro ao cadastrar veículo";

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
