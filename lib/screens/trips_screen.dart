import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = sampleTrips.where((t) => t.status == TripStatus.pending || t.status == TripStatus.inProgress).toList();
    final completed = sampleTrips.where((t) => t.status == TripStatus.completed || t.status == TripStatus.cancelled).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: REGISTheme.accentLight,
          labelColor: REGISTheme.accentLight,
          unselectedLabelColor: REGISTheme.textSecondary,
          tabs: [
            Tab(text: 'Pendentes (${pending.length})'),
            Tab(text: 'Histórico (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // _TripList(trips: pending, emptyMsg: 'Nenhuma viagem pendente'),
          // _TripList(trips: completed, emptyMsg: 'Nenhum histórico de viagens'),
        ],
      ),
    );
  }
}

// class _TripList extends StatelessWidget {
//   final List<Trip> trips;
//   final String emptyMsg;

//   const _TripList({required this.trips, required this.emptyMsg});

//   @override
//   Widget build(BuildContext context) {
//     if (trips.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.inbox_rounded, size: 64, color: REGISTheme.textSecondary.withOpacity(0.3)),
//             const SizedBox(height: 16),
//             Text(emptyMsg, style: const TextStyle(color: REGISTheme.textSecondary)),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: trips.length,
//       itemBuilder: (_, i) => _TripItem(
//         trip: trips[i],
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => TripDetailS·creen(trip: trips[i])),
//         ),
//       ),
//     );
//   }
// }

class TripItem extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripItem({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    
    switch (trip.status) {
      case TripStatus.pending:
        statusColor = REGISTheme.warning;
        statusLabel = 'pendente';
        break;
      case TripStatus.inProgress:
        statusColor = REGISTheme.accentLight;
        statusLabel = 'em_transporte';
        break;
      case TripStatus.completed:
        statusColor = REGISTheme.success;
        statusLabel = 'entregue';
        break;
      case TripStatus.cancelled:
        statusColor = REGISTheme.danger;
        statusLabel = 'rejeitada';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: REGISTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: REGISTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.origin,
                        style: const TextStyle(
                          color: REGISTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_downward, size: 14, color: REGISTheme.textSecondary),
                      Text(
                        trip.destination,
                        style: const TextStyle(
                          color: REGISTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${trip.price.toStringAsFixed(0)} Kz',
                      style: const TextStyle(
                        color: REGISTheme.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: REGISTheme.divider, height: 20),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: REGISTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(trip.departureTime),
                  style: const TextStyle(color: REGISTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 14, color: REGISTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${trip.passengers.length} passageiros',
                  style: const TextStyle(color: REGISTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
