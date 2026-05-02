import 'package:flutter/material.dart';
import 'package:registagrodriver/components/showMOdalBottomSheetCreateRoutess/modal_bottomsheet_create_routes.dart';
import 'package:registagrodriver/models/vehicle/vehicle_model.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class VehiclesAvailable extends StatefulWidget {
  const VehiclesAvailable({super.key});

  @override
  State<VehiclesAvailable> createState() => _VehiclesAvailableState();
}

class _VehiclesAvailableState extends State<VehiclesAvailable> {
  final List<VehicleModel> _vehicles = [
    VehicleModel(
      id: '1',
      brand: 'Toyota',
      model: 'Hiace',
      color: 'Branco',
      typology: 'Minibus',
      plate: 'LD-00-00-AA',
      year: '2020',
      capacity: '15',
    ),
  ];

  Future<void> _createVehicle() async {
    final newVehicle = await showCreateVehicle(context);
    if (newVehicle != null) {
      setState(() => _vehicles.add(newVehicle));
    }
  }

  Future<void> _editVehicle(VehicleModel vehicle) async {
    final updated = await showEditVehicle(context, vehicle);
    if (updated != null) {
      setState(() {
        final index = _vehicles.indexWhere((v) => v.id == updated.id);
        if (index != -1) _vehicles[index] = updated;
      });
    }
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar veículo'),
        content: Text(
          'Tem a certeza que quer eliminar o veículo "${vehicle.brand} ${vehicle.model}"?\n'
          'Esta acção não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _vehicles.removeWhere((v) => v.id == vehicle.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veículo "${vehicle.brand} ${vehicle.model}" eliminado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            toolbarHeight: 70,
            backgroundColor: REGISTheme.cardBg,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              centerTitle: false,
              title: const Text(
                "Veículos disponíveis",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          _vehicles.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _VehicleCard(
                          vehicle: _vehicles[index],
                          onEdit: () => _editVehicle(_vehicles[index]),
                          onDelete: () => _deleteVehicle(_vehicles[index]),
                        ),
                      ),
                      childCount: _vehicles.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: REGISTheme.cardBg,
        onPressed: _createVehicle,
        tooltip: 'Adicionar veículo',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhum veículo disponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar o primeiro veículo.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: REGISTheme.cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: TextStyle(
                        color: REGISTheme.cardBg,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      vehicle.typology,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  icon: Icons.palette_outlined,
                  label: 'Cor',
                  value: vehicle.color
                ),
              ),
              if (vehicle.plate != null)
                Expanded(
                  child: _detailItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Matrícula',
                    value: vehicle.plate!
                  ),
                ),
            ],
          ),
          if (vehicle.year != null || vehicle.capacity != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (vehicle.year != null)
                  Expanded(
                    child: _detailItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Ano',
                      value: vehicle.year!
                    ),
                  ),
                if (vehicle.capacity != null)
                  Expanded(
                    child: _detailItem(
                      icon: Icons.people_outline,
                      label: 'Capacidade',
                      value: '${vehicle.capacity}kg'
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Editar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: REGISTheme.cardBg,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.red.shade600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}