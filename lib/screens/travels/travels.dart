import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/screens/travels/all_travels/all_tavels.dart';
import 'package:registagrodriver/screens/travels/confirmed_travel/confirmedTravels.dart';
import 'package:registagrodriver/screens/travels/finish_travels/finish_travels.dart';
import 'package:registagrodriver/screens/travels/pending_travels/pending_travels.dart';
import 'package:registagrodriver/theme/app_theme.dart';

  final List<Map<String, String>> todasCorridas = [
    {
      'fazenda': 'Fazenda Filomena',
      'status': 'Pendente',
      'origem': 'AGT - Administração Geral Tributária',
      'destino': 'TIS TECH ANGOLA',
      'quantidade': '320kg/cx',
      'produto': 'Tomate',
      'oferta': '88.000kz',
    },
    {
      'fazenda': 'Fazenda Bela Vista',
      'status': 'Confirmado',
      'origem': 'Mercado do Kinaxixi',
      'destino': 'Porto de Luanda',
      'quantidade': '150kg/cx',
      'produto': 'Batata',
      'oferta': '45.000kz',
    },
    {
      'fazenda': 'Fazenda São João',
      'status': 'Entregue',
      'origem': 'Viana Industrial',
      'destino': 'Mercado do Rocha Pinto',
      'quantidade': '200kg/cx',
      'produto': 'Cebola',
      'oferta': '60.000kz',
    },
    {
      'fazenda': 'Fazenda Santa Clara',
      'status': 'Pendente',
      'origem': 'Cacuaco - Zona Industrial',
      'destino': 'Mercado do Rangel',
      'quantidade': '180kg/cx',
      'produto': 'Alface',
      'oferta': '32.000kz',
    },
    {
      'fazenda': 'Fazenda Verde Vida',
      'status': 'Confirmado',
      'origem': 'Talatona - Sul',
      'destino': 'Supermercado Nosso Super',
      'quantidade': '500kg/cx',
      'produto': 'Mandioca',
      'oferta': '120.000kz',
    },
    {
      'fazenda': 'Fazenda Boa Esperança',
      'status': 'Entregue',
      'origem': 'Viana - Km 30',
      'destino': 'Mercado do Benfica',
      'quantidade': '250kg/cx',
      'produto': 'Milho',
      'oferta': '75.000kz',
    },
    {
      'fazenda': 'Fazenda Horizonte',
      'status': 'Pendente',
      'origem': 'Luanda Sul - Condomínio',
      'destino': 'Porto de Luanda',
      'quantidade': '400kg/cx',
      'produto': 'Feijão',
      'oferta': '95.000kz',
    },
    {
      'fazenda': 'Fazenda Nova Aurora',
      'status': 'Confirmado',
      'origem': 'Belas - Estrada Nacional',
      'destino': 'Shoprite Talatona',
      'quantidade': '300kg/cx',
      'produto': 'Arroz',
      'oferta': '110.000kz',
    },
    {
      'fazenda': 'Fazenda Primavera',
      'status': 'Entregue',
      'origem': 'Catete - Interior',
      'destino': 'Mercado do Kinaxixi',
      'quantidade': '220kg/cx',
      'produto': 'Banana',
      'oferta': '55.000kz',
    },
  ];

class MyTravels extends StatefulWidget {
  const MyTravels({super.key});

  @override
  State<MyTravels> createState() => _MyTravelsState();
}

class _MyTravelsState extends State<MyTravels> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: REGISTheme.surface,
          elevation: 0,
          title: const Text(
            "Minhas Viagens",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: SegmentedTabControl(
                tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                barDecoration: BoxDecoration(
                  color: REGISTheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                tabs: const [
                  SegmentTab(
                    label: 'Todas',
                    textColor: Colors.white54,
                    selectedTextColor: REGISTheme.primary,
                  ),
                  SegmentTab(
                    label: 'Pendentes',
                    textColor: Colors.white54,
                    selectedTextColor: REGISTheme.primary,
                  ),
                  SegmentTab(
                    label: 'Confirmadas',
                    textColor: Colors.white54,
                    selectedTextColor: REGISTheme.primary,
                  ),
                  SegmentTab(
                    label: 'Concluídas',
                    textColor: Colors.white54,
                    selectedTextColor: REGISTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllTab(corridas: todasCorridas),
            PendingTab(corridas: todasCorridas.where((c) => c['status'] == 'Pendente').toList()),
            ConfirmedTab(corridas: todasCorridas.where((c) => c['status'] == 'Confirmado').toList()),
            FinishTravelsTab(corridas: todasCorridas.where((c) => c['status'] == 'Entregue').toList()),
          ],
        ),
      ),
    );
  }
}