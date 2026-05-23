import 'package:flutter/material.dart';
import 'package:registagrodriver/components/show-follow-up-bottomSheet/follow_up.dart';
import 'package:registagrodriver/components/tirp_card/tirp_card.dart';

class PendingTab extends StatefulWidget {
  final List<Map<String, String>> corridas;
  const PendingTab({super.key, required this.corridas});

  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> {
  late List<Map<String, String>> _corridas;

  @override
  void initState() {
    super.initState();
    _corridas = List.from(widget.corridas);
  }

  void _removerCorrida(Map<String, String> corrida) {
    setState(() {
      _corridas.remove(corrida);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _corridas.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  itemCount: _corridas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final c = _corridas[index];
                    return Dismissible(
                      key: ValueKey('${c['fazenda']}_${c['oferta']}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removerCorrida(c),
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Remover',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        child: TripCard(
                          fazenda: c['fazenda']!,
                          status: c['status']!,
                          origem: c['origem']!,
                          destino: c['destino']!,
                          quantidade: c['quantidade']!,
                          produto: c['produto']!,
                          oferta: c['oferta']!,
                          onIniciar: () => showFollwoUp(context),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "Nenhuma viagem pendente",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "As viagens que você agendar aparecerão aqui.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}