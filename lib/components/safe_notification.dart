import 'package:flutter/material.dart';
import 'package:registagrodriver/components/topNotification/top_notification.dart';
import 'package:registagrodriver/utils/safe_error.dart';

/// Sanitized top notification — strips HTML/scripts and caps length.
void showSafeNotification(
  BuildContext context, {
  required String title,
  String? description,
  Color backgroundColor = const Color(0xFFC62828),
  IconData icon = Icons.error_outline,
  Color? titleColor,
  Color? descriptionColor,
  Color? iconColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final safeDesc = (description != null && description.isNotEmpty)
      ? SafeErrorMessages.sanitize(description)
      : SafeErrorMessages.generic;

  showTopNotification(
    context,
    title: SafeErrorMessages.sanitize(title),
    description: safeDesc,
    backgroundColor: backgroundColor,
    icon: icon,
    titleColor: titleColor,
    descriptionColor: descriptionColor,
    iconColor: iconColor,
    duration: duration,
  );
}
