import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:registagrodriver/models/vehicle/vehicle_model.dart';
import 'package:registagrodriver/theme/app_theme.dart';

const _typologies = ['Pickup', 'Carrinha', 'Camião'];

Future<VehicleModel?> showCreateVehicle(BuildContext context) {
  return _showVehicleDialog(context, existingVehicle: null);
}

Future<VehicleModel?> showEditVehicle(
  BuildContext context,
  VehicleModel existingVehicle,
) {
  return _showVehicleDialog(context, existingVehicle: existingVehicle);
}

Future<VehicleModel?> _showVehicleDialog(
  BuildContext context, {
  VehicleModel? existingVehicle,
}) {
  final isEditing = existingVehicle != null;
  final formKey = GlobalKey<FormState>();

  final brandController = TextEditingController(text: existingVehicle?.brand ?? '');
  final modelController = TextEditingController(text: existingVehicle?.model ?? '');
  final colorController = TextEditingController(text: existingVehicle?.color ?? '');
  final plateController = TextEditingController(text: existingVehicle?.plate ?? '');
  final yearController =  TextEditingController(text: existingVehicle?.year ?? '');
  final capacityController = TextEditingController(text: existingVehicle?.capacity ?? '');
  final selectedTypology = ValueNotifier<String?>(existingVehicle?.typology);

  return showDialog<VehicleModel>(
    context: context,
    builder: (_) => KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isKeyboardVisible ? 16 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar veículo' : 'Adicionar veículo',
                              style: TextStyle(
                                color: REGISTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEditing ? 'Actualize os dados do veículo' : 'Preencha os dados do novo veículo',
                              style: TextStyle(color: REGISTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: brandController,
                                label: 'Marca',
                                hint: 'Ex: Toyota',
                                icon: Icons.directions_car,
                                validator: _required('Marca é obrigatória'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: modelController,
                                label: 'Modelo',
                                hint: 'Ex: Hiace',
                                icon: Icons.car_repair,
                                validator: _required('Modelo é obrigatório'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: colorController,
                          label: 'Cor',
                          hint: 'Ex: Branco',
                          icon: Icons.palette_outlined,
                          validator: _required('Cor é obrigatória'),
                        ),
                        const SizedBox(height: 14),

                        ValueListenableBuilder<String?>(
                          valueListenable: selectedTypology,
                          builder: (context, typology, _) {
                            return DropdownButtonFormField<String>(
                              value: typology,
                              decoration: InputDecoration(
                                labelText: 'Tipologia',
                                prefixIcon: const Icon(Icons.category_outlined,size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              hint: const Text('Seleccione a tipologia'),
                              items: _typologies.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => selectedTypology.value = val,
                              validator: (val) => val == null ? 'Tipologia é obrigatória' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: plateController,
                          label: 'Matrícula',
                          hint: 'Ex: LD-00-00-AA',
                          icon: Icons.credit_card_outlined,
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (old, newVal) => TextEditingValue(
                                text: newVal.text.toUpperCase(),
                                selection: newVal.selection,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: yearController,
                                label: 'Ano',
                                hint: 'Ex: 2020',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: capacityController,
                                label: 'Capacidade',
                                hint: 'Ex: 1500kg ',
                                icon: Icons.people_outline,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final vehicle = VehicleModel(
                                  id: existingVehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                  brand: brandController.text.trim(),
                                  model: modelController.text.trim(),
                                  color: colorController.text.trim(),
                                  typology: selectedTypology.value!,
                                  plate: plateController.text.trim().isEmpty ? null : plateController.text.trim(),
                                  year: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                                  capacity: capacityController.text.trim().isEmpty ? null : capacityController.text.trim(),
                                );
                                Navigator.of(context).pop(vehicle);
                              }
                            },
                            icon: Icon(
                              isEditing ? Icons.save_outlined : Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: Text(
                              isEditing ? 'Salvar alterações' : 'Adicionar Veículo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: REGISTheme.cardBg,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildField({
  required TextEditingController controller,
  required String label,
  String? hint,
  required IconData icon,
  Color? iconColor,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

String? Function(String?) _required(String msg) {
  return (value) => (value == null || value.trim().isEmpty) ? msg : null;
}