import 'dart:io';

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
import 'package:registagrodriver/utils/upload_validator.dart';

class VehicleRepositorie implements IVehicleRepository {
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

      if (tokenMap.containsKey('error') || tokenMap['token'] == null) {
        Profile().handleAuthError(
          context,
          tokenMap['error'] ?? SafeErrorMessages.sessionExpired,
        );
        throw Exception('Error');
      }

      final dio = DioClient().dio;
      final res = await dio.get(ApiConfig.carrierVehicles);

      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      final json = res.data as Map<String, dynamic>? ?? {};
      final List<dynamic> items = json['vehicles'] as List<dynamic>? ?? [];

      return items
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
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

      rethrow;
    } catch (e) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      Profile().handleAuthError(context, SafeErrorMessages.generic);
      throw Exception('Error');
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
    final uploadError = UploadValidator.validateImage(img);
    if (uploadError != null) {
      showSafeNotification(
        context,
        title: 'Erro',
        description: uploadError,
      );
      throw Exception(uploadError);
    }

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

      final ext = img.path.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'png' => DioMediaType('image', 'png'),
        'webp' => DioMediaType('image', 'webp'),
        'jpg' => DioMediaType('image', 'jpg'),
        _ => DioMediaType('image', 'jpeg'),
      };

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          img.path,
          filename: img.path.split(RegExp(r'[/\\]')).last,
          contentType: contentType,
        ),
        'brand': brand,
        'plate': plate,
        'category': category,
        'capacity': capacity,
        'unit': unit,
      });

      final res = await dio.post(ApiConfig.vehicleCreate, data: formData);

      if (context.mounted) Navigator.of(context).pop();

      final json = res.data as Map<String, dynamic>? ?? {};
      return json['message'] as String? ?? '';
    } on DioException catch (e) {
      if (context.mounted) Navigator.of(context).pop();

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
}
