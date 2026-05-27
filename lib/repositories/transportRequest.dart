import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/components/topNotification/top_notification.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/storage.dart';

class TransportRequest {
  Future<List<Transport>> getRequests(
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
        "https://api-registagro.onrender.com/transports/carrier/request/get",
      );

      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      final json = res.data as Map<String, dynamic>? ?? {};
      final List<dynamic> items = json['requests'] as List<dynamic>? ?? [];

      return items
          .map((item) => Transport.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      String message = "Erro ao carregar suas solicitações";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = e.response?.data?['error'] ?? 'Sessão expirada';

        Profile().handleAuthError(context, message);
      } else {
        message =
            e.response?.data?['error'] ??
            e.response?.data?['info'] ??
            e.message ??
            message;

        e.response?.data["error"] != null || e.response?.data["info"] != null
            ? showTopNotification(
                context,
                title: "Error",
                description: message,
                backgroundColor: Colors.red.shade700,
                icon: Icons.error_outline,
              )
            : print(message);
      }

      throw Exception(message);
    } catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      Profile().handleAuthError(context, "Ocorreu um erro inesperado");

      throw Exception("Error");
    }
  }

  Future<String> acceptRequest(
    BuildContext context,
    String requestId,
    String latitude,
    String longitude,
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
        BaseOptions(
          headers: {
            "content-type": "application/json",
            "authorization": "Bearer ${tokenMap["token"]}",
          },
        ),
      );

      final res = await dio.patch(
        "https://api-registagro.onrender.com/transports/carrier/request/accept",
        data: {
          "requestId": requestId,
          "latitude": latitude,
          "longitude": longitude,
        },
      );

      Navigator.of(context).pop();

      final json = res.data as Map<String, dynamic>? ?? {};
      final String message = json["message"] as String? ?? "";

      return message;
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

  Future<String> finishFlow(BuildContext context, String requestId) async {

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

      final res = await dio.patch(
        "https://api-registagro.onrender.com/flow/carrier/finish/request/$requestId",
      );


      final json = res.data as Map<String, dynamic>? ?? {};
      final String message = json["message"] as String? ?? "";

      return message;
    } on DioException catch (e) {

      String message = "Erro ao terminar corrida";

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

      Profile().handleAuthError(context, "Ocorreu um erro inesperado");

      throw Exception("Error");
    }
  }
}
