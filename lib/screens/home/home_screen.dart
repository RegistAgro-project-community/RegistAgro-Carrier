import 'package:flutter/material.dart';
import 'package:registagrodriver/components/show-follow-up-bottomSheet/follow_up.dart';
import 'package:registagrodriver/components/tirp_card/tirp_card.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  bool isDisponivel = false;

  final List<Map<String, String>> corridas = [
    {
      'fazenda': 'Fazenda Filomena',
      'status': 'Confirmado',
      'origem': 'AGT - Administração Geral Tributária',
      'destino': 'TIS TECH ANGOLA',
      'quantidade': '320kg/cx',
      'produto': 'Tomate',
      'oferta': '88.000kz',
    },
    {
      'fazenda': 'Fazenda Bela Vista',
      'status': 'Pendente',
      'origem': 'Mercado do Kinaxixi',
      'destino': 'Porto de Luanda',
      'quantidade': '150kg/cx',
      'produto': 'Batata',
      'oferta': '45.000kz',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: REGISTheme.surface,
        title: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total: 00,0kz",
                style: TextStyle(fontSize: 18),
              ),
              const CircleAvatar(radius: 20),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, João Cabinda!",
                  style: TextStyle(
                    color: REGISTheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Inicie uma corrida para melhorar a experiência.",
                  style: TextStyle(
                    fontSize: 12,
                    color: REGISTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 231, 231, 231),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_box_rounded,
                            color: isDisponivel ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${isDisponivel ? "Disponível" : "Indisponível"} para viagens",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        value: isDisponivel,
                        onChanged: (val) => setState(() => isDisponivel = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Próximas viagens",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: corridas.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                      itemCount: corridas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final c = corridas[index];
                        return TripCard(
                          fazenda: c['fazenda']!,
                          status: c['status']!,
                          origem: c['origem']!,
                          destino: c['destino']!,
                          quantidade: c['quantidade']!,
                          produto: c['produto']!,
                          oferta: c['oferta']!,
                          onIniciar: () => showFollwoUp(context),
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            "Sem viagens disponíveis",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Aguarde! Novas corridas aparecerão aqui em breve.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}