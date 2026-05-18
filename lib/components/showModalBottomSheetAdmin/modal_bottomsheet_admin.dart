import 'package:flutter/material.dart';
import 'package:registagrodriver/theme/app_theme.dart';

void showContactAdmin(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: REGISTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contactar Administrador',
              style: TextStyle(color: REGISTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Para problemas de acesso ou suporte técnico:',
              style: TextStyle(color: REGISTheme.textSecondary)),
          const SizedBox(height: 16),
          _contactRow(Icons.email_outlined, 'admin@registagro.ao'),
          const SizedBox(height: 8),
          _contactRow(Icons.phone_outlined, '+244 922 950 614'),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
Widget _contactRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: REGISTheme.accentLight, size: 20),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(color: REGISTheme.textPrimary)),
    ],
  );
}