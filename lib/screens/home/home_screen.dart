import 'package:flutter/material.dart';
import 'package:registagrodriver/components/show-follow-up-bottomSheet/follow_up.dart';
import 'package:registagrodriver/components/tirp_card/tirp_card.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  final String? balance;
  final String? photo;
  final List<Transport> requests;

  const HomeScreen({
    super.key,
    required this.name,
    required this.balance,
    required this.photo,
    required this.requests,
  });

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  bool isLoading = false;
  String value = "00,0Kz";
  bool isDisponivel = false;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.photo != null && widget.photo!.trim().isNotEmpty;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: REGISTheme.surface,
        title: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${widget.balance ?? value}",
                style: TextStyle(fontSize: 18),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: hasPhoto
                    ? NetworkImage(widget.photo!)
                    : null,
                child: !hasPhoto
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: REGISTheme.accentLight,
                      )
                    : null,
              )
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
                  widget.name != null ? "Olá, ${widget.name}!" : "Olá!",
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
                  child:
                      widget.requests
                          .where((r) => r.status == "pendente")
                          .isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          itemCount:
                              widget.requests
                                      .where((r) => r.status == "pendente")
                                      .length >
                                  2
                              ? 2
                              : widget.requests
                                    .where((r) => r.status == "pendente")
                                    .length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final c =
                                widget.requests[index].status == "pendente"
                                ? widget.requests[index]
                                : null;

                            if (widget.requests[index].status == "pendente") {
                              return TripCard(
                                fazenda: c!.farm.name!,
                                status: c.status!,
                                origem: "${c.farm.province}, ${c.farm.adress}",
                                destino: c.order.delivery_adress ?? "",
                                quantidade: c.order.qtd ?? "",
                                produto: c.order.productName ?? "",
                                oferta: c.order.earning ?? "",
                                photo: c.farm.profile ?? "",
                                onIniciar: () => showFollwoUp(context),
                              );
                            }

                            return null;
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
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
