import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart' as m;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<m.Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(m.sampleNotifications);
  }

  void markAllRead() {
    setState(() {
      _notifications = _notifications
        .map((n) => m.Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          time: n.time,
          isRead: true,
          type: n.type,
        )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações')
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                'Sem notificações', 
                style: TextStyle(
                  color: REGISTheme.textSecondary
                )
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (_, i) => _NotifCard(
                notif: _notifications[i],
                onTap: () => setState(() {
                  _notifications[i] = m.Notification(
                    id: _notifications[i].id,
                    title: _notifications[i].title,
                    message: _notifications[i].message,
                    time: _notifications[i].time,
                    isRead: true,
                    type: _notifications[i].type,
                  );
                }),
                onDismiss: () => setState(() => _notifications.removeAt(i)),
              ),
            ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final m.Notification notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({required this.notif, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (notif.type) {
      case 'success':
        typeColor = REGISTheme.success;
        typeIcon = Icons.check_circle_outline_rounded;
        break;
      case 'warning':
        typeColor = REGISTheme.warning;
        typeIcon = Icons.warning_amber_rounded;
        break;
      default:
        typeColor = REGISTheme.accentLight;
        typeIcon = Icons.info_outline_rounded;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: REGISTheme.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: REGISTheme.danger),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isRead ? REGISTheme.cardBg : REGISTheme.cardBg.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead ? REGISTheme.divider : typeColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              color: REGISTheme.textPrimary,
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: REGISTheme.accentLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: const TextStyle(color: REGISTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notif.time),
                      style: TextStyle(color: REGISTheme.textSecondary.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'Há ${diff.inHours} horas';
    return 'Há ${diff.inDays} dias';
  }
}
