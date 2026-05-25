import 'package:flutter/material.dart';
import 'package:registagrodriver/components/show-follow-up-bottomSheet/follow_up.dart';
import 'package:registagrodriver/components/tirp_card/tirp_card.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';

class AllTab extends StatefulWidget {
  final List<Transport> requests;
  const AllTab({super.key, required this.requests});

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  //late List<Transport> _corridas;

  @override
  void initState() {
    super.initState();
    //_corridas = List.from(widget.requests);
  }

  /*void _removerCorrida(Transport corrida) {
    setState(() {
      _corridas.remove(corrida);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: widget.requests.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                itemCount: widget.requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final c = widget.requests[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: TripCard(
                      fazenda: c.farm.name!,
                      status: c.status!,
                      origem: "${c.farm.province}, ${c.farm.adress}",
                      destino: c.order.delivery_adress!,
                      quantidade: c.order.qtd!,
                      produto: c.order.productName!,
                      oferta: c.order.earning!,
                      photo: c.farm.profile!,
                      onIniciar: () => showFollwoUp(context),
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
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "Nenhuma viagem disponível",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Todas as suas viagens aparecerão aqui.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}