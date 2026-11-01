import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/components/safe_notification.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:registagrodriver/repositories/interfaces/repositories.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/storage.dart';
import 'package:registagrodriver/services/dio_client.dart';
import 'package:registagrodriver/utils/safe_error.dart';

class TransportRequest implements ITransportRepository {
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

      if (tokenMap.containsKey('error') || tokenMap['token'] == null) {
        Profile().handleAuthError(
          context,
          tokenMap['error'] ?? SafeErrorMessages.sessionExpired,
        );
        throw Exception('Error');
      }

      final dio = DioClient().dio;
      final res = await dio.get(ApiConfig.carrierRequests);

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

      final message = SafeErrorMessages.fromDio(e);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        Profile().handleAuthError(context, SafeErrorMessages.sessionExpired);
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

      if (e is! Exception || e.toString() != 'Exception: Error') {
        Profile().handleAuthError(context, SafeErrorMessages.generic);
      }

      throw Exception('Error');
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

      if (tokenMap.containsKey('error') || tokenMap['token'] == null) {
        Profile().handleAuthError(
          context,
          tokenMap['error'] ?? SafeErrorMessages.sessionExpired,
        );
        throw Exception('Error');
      }

      final dio = DioClient().dio;
      final res = await dio.patch(
        ApiConfig.carrierAccept,
        data: {
          'requestId': requestId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (context.mounted) Navigator.of(context).pop();

      final json = res.data as Map<String, dynamic>? ?? {};
      return json['message'] as String? ?? '';
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      final message = SafeErrorMessages.fromDio(e);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        Profile().handleAuthError(context, SafeErrorMessages.sessionExpired);
      } else if (context.mounted) {
        showSafeNotification(
          context,
          title: 'Erro',
          description: message,
        );
      }

      throw Exception(message);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      Profile().handleAuthError(context, SafeErrorMessages.generic);
      throw Exception('Error');
    }
  }

  Future<String> finishFlow(BuildContext context, String requestId) async {
    try {
      final tokenMap = await TokenStorage().readToken();

      if (tokenMap.containsKey('error') || tokenMap['token'] == null) {
        Profile().handleAuthError(
          context,
          tokenMap['error'] ?? SafeErrorMessages.sessionExpired,
        );
        throw Exception('Error');
      }

      final dio = DioClient().dio;
      final res = await dio.patch(ApiConfig.carrierFinish(requestId));

      final json = res.data as Map<String, dynamic>? ?? {};
      return json['message'] as String? ?? '';
    } on DioException catch (e) {
      final message = SafeErrorMessages.fromDio(e);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        Profile().handleAuthError(context, SafeErrorMessages.sessionExpired);
      } else if (context.mounted) {
        showSafeNotification(
          context,
          title: 'Erro',
          description: message,
        );
      }

      throw Exception(message);
    } catch (e) {
      Profile().handleAuthError(context, SafeErrorMessages.generic);
      throw Exception('Error');
    }
  }
}
