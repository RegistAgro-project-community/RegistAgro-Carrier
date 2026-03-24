import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Viagem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and type
            Row(
              children: [
                
                const Spacer(),
                Text(
                  'ID: ${trip.id}',
                  style: const TextStyle(color: REGISTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Route card
            _Section(
              title: 'Rota da Viagem',
              child: Column(
                children: [
                  _RouteRow(
                    icon: Icons.radio_button_checked,
                    color: REGISTheme.accentLight,
                    label: 'Origem',
                    value: trip.origin,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 11),
                    height: 20,
                    width: 2,
                    color: REGISTheme.divider,
                  ),
                  _RouteRow(
                    icon: Icons.location_on_rounded,
                    color: REGISTheme.success,
                    label: 'Destino',
                    value: trip.destination,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            _Section(
              title: 'Informações',
              child: Column(
                children: [
                  
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Passengers
            _Section(
              title: 'Passageiros (${trip.passengers.length})',
              child: Column(
                children: trip.passengers.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Nenhum passageiro ainda',
                            style: TextStyle(color: REGISTheme.textSecondary),
                          ),
                        )
                      ]
                    : trip.passengers
                        .map((p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: const TextStyle(
                                              color: REGISTheme.textPrimary,
                                              fontWeight: FontWeight.w600)),
                                      Text(p.phone,
                                          style: const TextStyle(
                                              color: REGISTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: REGISTheme.warning, size: 14),
                                      const SizedBox(width: 2),
                                      Text(p.rating.toString(),
                                          style: const TextStyle(
                                              color: REGISTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Map
            const SizedBox(height: 24),

            // Actions
            if (trip.status == TripStatus.pending) ...[
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viagem iniciada!'),
                      backgroundColor: REGISTheme.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Iniciar Viagem'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: REGISTheme.divider),
                  foregroundColor: REGISTheme.textSecondary,
                ),
                child: const Text('Cancelar Viagem'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String statusLabel(TripStatus s) {
    switch (s) {
      case TripStatus.pending: return 'Pendente';
      case TripStatus.inProgress: return 'Em Curso';
      case TripStatus.completed: return 'Concluída';
      case TripStatus.cancelled: return 'Cancelada';
    }
  }

  Color statusColor(TripStatus s) {
    switch (s) {
      case TripStatus.pending: return REGISTheme.warning;
      case TripStatus.inProgress: return REGISTheme.accentLight;
      case TripStatus.completed: return REGISTheme.success;
      case TripStatus.cancelled: return REGISTheme.danger;
    }
  }

  String typeLabel(TripType t) {
    switch (t) {
      case TripType.passenger: return 'Passageiros';
      case TripType.cargo: return 'Carga';
      case TripType.mixed: return 'Misto';
    }
  }

  Color typeColor(TripType t) {
    switch (t) {
      case TripType.passenger: return REGISTheme.accent;
      case TripType.cargo: return REGISTheme.warning;
      case TripType.mixed: return REGISTheme.success;
    }
  }

  String formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: REGISTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: REGISTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: REGISTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: REGISTheme.textSecondary, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: REGISTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}
