import 'package:flutter/material.dart';
import 'package:registagrodriver/components/showMOdalBottomSheetCreateRoutess/modal_bottomsheet_create_routes.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/vehicle.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class VehiclesAvailable extends StatefulWidget {
  final List<Vehicle> vehicles;
  const VehiclesAvailable({super.key, required this.vehicles});

  @override
  State<VehiclesAvailable> createState() => _VehiclesAvailableState();
}

class _VehiclesAvailableState extends State<VehiclesAvailable> {
  Future<void> _createVehicle() async {
    final result = await showCreateVehicle(context);
    if (result == null) return;

    if (result.imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione uma foto para o veículo.")),
      );
      return;
    }

    await VehicleRepositorie().createVehicle(
      context,
      result.brand!,
      result.plate ?? "",
      result.type ?? "",
      int.tryParse(result.capacity ?? "0") ?? 0,
      result.unit ?? "kg",
      result.imageFile!,
    );

    setState(() => widget.vehicles.add(result));
  }

  Future<void> _editVehicle(Vehicle vehicle) async {
    final updated = await showEditVehicle(context, vehicle);
    if (updated != null) {
      setState(() {
        final index = widget.vehicles.indexWhere((v) => v.id == updated.id);
        if (index != -1) widget.vehicles[index] = updated;
      });
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar veículo'),
        content: Text(
          'Tem a certeza que quer eliminar o veículo "${vehicle.brand}"?\n'
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
      setState(() => widget.vehicles.removeWhere((v) => v.id == vehicle.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veículo "${vehicle.brand}" eliminado.'),
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
            automaticallyImplyLeading: false,
            backgroundColor: REGISTheme.cardBg,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              centerTitle: false,
              title: const Text(
                "Meus Veículos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          widget.vehicles.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _VehicleCard(
                          vehicle: widget.vehicles[index],
                          onEdit: () => _editVehicle(widget.vehicles[index]),
                          onDelete: () =>
                              _deleteVehicle(widget.vehicles[index]),
                        ),
                      ),
                      childCount: widget.vehicles.length,
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
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
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
  final Vehicle vehicle;
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
              CircleAvatar(
                radius: 20,
                backgroundColor: REGISTheme.accentLight,
                backgroundImage: vehicle.photo != ""
                    ? NetworkImage(vehicle.photo!)
                    : null,
                child: vehicle.photo == ""
                    ? const Icon(
                        Icons.directions_car,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand}',
                      style: TextStyle(
                        color: REGISTheme.cardBg,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      vehicle.type ?? "",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              if (vehicle.plate != null)
                Expanded(
                  child: _detailItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Matrícula',
                    value: vehicle.plate!,
                  ),
                ),
            ],
          ),
          if (vehicle.capacity != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (vehicle.capacity != null)
                  Expanded(
                    child: _detailItem(
                      icon: Icons.people_outline,
                      label: 'Capacidade',
                      value: '${vehicle.capacity}',
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
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
