import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  String _type = 'passenger';
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: REGISTheme.accent,
            onPrimary: Colors.white,
            surface: REGISTheme.cardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: REGISTheme.accent,
              onPrimary: Colors.white,
              surface: REGISTheme.cardBg,
            ),
          ),
          child: child!,
        ),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _submit() async {
    if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha origem e destino'),
          backgroundColor: REGISTheme.danger,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viagem criada com sucesso!'),
          backgroundColor: REGISTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação de Transporte'),
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
            // Type selector
            const Text('Tipo de Transporte',
                style: TextStyle(color: REGISTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: REGISTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: REGISTheme.divider),
              ),
              child: Row(
                children: [
                  _typeBtn('passenger', 'Passageiros', Icons.person_rounded),
                  _typeBtn('cargo', 'Carga', Icons.inventory_2_rounded),
                  _typeBtn('mixed', 'Misto', Icons.swap_horiz_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Rota', style: TextStyle(color: REGISTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _originController,
              style: const TextStyle(color: REGISTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Ponto de Partida',
                prefixIcon: Icon(Icons.radio_button_checked, color: REGISTheme.accentLight, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              style: const TextStyle(color: REGISTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Destino',
                prefixIcon: Icon(Icons.location_on_rounded, color: REGISTheme.success, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),

            const Text('Detalhes', style: TextStyle(color: REGISTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),

            // Date time picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: REGISTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: REGISTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: REGISTheme.textSecondary, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      _formatDateTime(_selectedDate),
                      style: const TextStyle(color: REGISTheme.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: REGISTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _seatsController,
                    style: const TextStyle(color: REGISTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Lugares',
                      prefixIcon: Icon(Icons.airline_seat_recline_normal_rounded,
                          color: REGISTheme.textSecondary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    style: const TextStyle(color: REGISTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Preço (Kz)',
                      prefixIcon: Icon(Icons.attach_money, color: REGISTheme.textSecondary, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publicar Viagem'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String value, String label, IconData icon) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? REGISTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : REGISTheme.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : REGISTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
