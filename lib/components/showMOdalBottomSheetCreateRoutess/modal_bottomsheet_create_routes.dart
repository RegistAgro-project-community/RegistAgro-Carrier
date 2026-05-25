import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:image_picker/image_picker.dart';
import 'package:registagrodriver/theme/app_theme.dart';

const _typologies = [
  'frigorifico',
  'fechado',
  'aberto',
  'fechado',
  "aberto_coberto",
];

Future<Vehicle?> showCreateVehicle(BuildContext context) {
  return _showVehicleDialog(context, existingVehicle: null);
}

Future<Vehicle?> showEditVehicle(
  BuildContext context,
  Vehicle existingVehicle,
) {
  return _showVehicleDialog(context, existingVehicle: existingVehicle);
}

Future<Vehicle?> _showVehicleDialog(
  BuildContext context, {
  Vehicle? existingVehicle,
}) {
  final isEditing = existingVehicle != null;
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final brandController = TextEditingController(
    text: existingVehicle?.brand ?? '',
  );
  final plateController = TextEditingController(
    text: existingVehicle?.plate ?? '',
  );
  final capacityController = TextEditingController(
    text: existingVehicle?.capacity ?? '',
  );
  final selectedTypology = ValueNotifier<String?>(
    existingVehicle?.type?.isNotEmpty == true ? existingVehicle!.type : null,
  );
  final photoController = TextEditingController(text: existingVehicle?.photo);
  final selectedImage = ValueNotifier<File?>(null);

  void _selectImgage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        photoController.text = pickedFile.path;
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Não foi possível abrir a galeria. Tente novamente."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  return showDialog<Vehicle>(
    context: context,
    builder: (_) => KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                              isEditing
                                  ? 'Editar veículo'
                                  : 'Adicionar veículo',
                              style: TextStyle(
                                color: REGISTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEditing
                                  ? 'Actualize os dados do veículo'
                                  : 'Preencha os dados do novo veículo',
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

                  Center(
                    child: GestureDetector(
                      onTap: () => _selectImgage(),
                      child: ValueListenableBuilder<File?>(
                        valueListenable: selectedImage,
                        builder: (context, file, _) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 3,
                              ),
                              image: (file != null)
                                  ? DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    )
                                  : (existingVehicle?.photo?.isNotEmpty == true)
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        existingVehicle!.photo!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (file == null &&
                                    existingVehicle?.photo?.isEmpty != false)
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Toque para alterar a foto",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                          ],
                        ),
                        const SizedBox(height: 14),

                        ValueListenableBuilder<String?>(
                          valueListenable: selectedTypology,
                          builder: (context, currentValue, _) {
                            return DropdownButtonFormField<String>(
                              value: currentValue,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Tipo',
                                prefixIcon: const Icon(
                                  Icons.category_outlined,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              hint: const Text('Seleccione o tipo'),
                              items: _typologies
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => selectedTypology.value = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? "O tipo é obrigatório"
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: plateController,
                          label: 'Matrícula',
                          hint: 'Ex: LDA-00-00-AA',
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
                                final vehicle = Vehicle(
                                  id:
                                      existingVehicle?.id ??
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  brand: brandController.text.trim(),
                                  plate: plateController.text.trim().isEmpty
                                      ? null
                                      : plateController.text.trim(),
                                  capacity:
                                      capacityController.text.trim().isEmpty
                                      ? null
                                      : capacityController.text.trim(),
                                  photo: photoController.text.trim().isEmpty
                                      ? null
                                      : photoController.text.trim(),
                                  type: selectedTypology.value,
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
                              isEditing
                                  ? 'Salvar alterações'
                                  : 'Adicionar Veículo',
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
