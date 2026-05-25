import 'package:flutter/material.dart';

void showTopNotification(
  BuildContext context, {
  required String title,
  required String description,
  required Color backgroundColor,
  Color? titleColor,
  Color? descriptionColor,
  Color? iconColor,
  required IconData icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: 50, 
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                      style: TextStyle(
                            color: titleColor, fontWeight: FontWeight.bold, fontSize: 16
                          )
                        ),
                    const SizedBox(height: 1.5),
                    Text(description,
                        style: TextStyle(color: descriptionColor, fontSize: 14
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(overlayEntry);
  Future.delayed(duration, () => overlayEntry.remove());
}
