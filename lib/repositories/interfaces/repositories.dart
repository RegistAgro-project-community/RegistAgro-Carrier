import 'package:flutter/material.dart';
import 'package:registagrodriver/models/direction_model.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/screens/profile/profile_class.dart';

/// ISP — auth domain only.
abstract class IAuthRepository {
  Future<Map<String, String>> login(
    String email,
    String password, {
    String? captchaToken,
  });
}

/// ISP — transport requests domain.
abstract class ITransportRepository {
  Future<List<Transport>> getRequests(
    BuildContext context, {
    bool showLoading = true,
  });

  Future<String> acceptRequest(
    BuildContext context,
    String requestId,
    String latitude,
    String longitude,
  );

  Future<String> finishFlow(BuildContext context, String requestId);
}

/// ISP — vehicle domain.
abstract class IVehicleRepository {
  Future<List<Vehicle>> getVehicle(
    BuildContext context, {
    bool showLoading = true,
  });
}

/// ISP — profile domain.
abstract class IProfileRepository {
  Future<UserModel> userData(
    BuildContext context, {
    bool showLoading = true,
  });

  Future<void> logout(BuildContext context);
}

/// ISP — geolocation / directions.
abstract class IGeolocationRepository {
  Future<DirectionModel> getCoordinates(
    String requestId,
  );
}
