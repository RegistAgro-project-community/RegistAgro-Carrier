import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/screens/travels/all_travels/all_tavels.dart';
import 'package:registagrodriver/screens/travels/confirmed_travel/confirmedTravels.dart';
import 'package:registagrodriver/screens/travels/finish_travels/finish_travels.dart';
import 'package:registagrodriver/screens/travels/pending_travels/pending_travels.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class MyTravels extends StatefulWidget {
  final List<Transport> requests;
  const MyTravels({super.key, required this.requests});

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
          automaticallyImplyLeading: false,
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
            AllTab(requests: widget.requests),
            PendingTab(
              requests: widget.requests
                  .where((c) => c.status == 'pendente')
                  .toList(),
            ),
            ConfirmedTab(
              requests: widget.requests
                  .where((c) => c.status == 'em_transporte' || c.status == "aguardando_coleta")
                  .toList(),
            ),
            FinishTravelsTab(
              requests: widget.requests
                  .where((c) => c.status == 'entregue')
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
