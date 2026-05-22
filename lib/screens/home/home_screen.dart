import 'package:flutter/material.dart';
import 'package:registagrodriver/components/show-follow-up-bottomSheet/follow_up.dart';
import 'package:registagrodriver/components/tirp_card/tirp_card.dart';
import 'package:registagrodriver/theme/app_theme.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>  {
  bool isLoading = false;
  String value = "00,0";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: REGISTheme.surface,
        title: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${value}kz",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              CircleAvatar(
                radius: 20,      
              )
            ],
          ),
        )
        
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
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
                SizedBox(height: 30),
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                        spacing: 1,
                        children: [
                          Icon(
                            Icons.check_box_rounded,
                            color: isLoading ? Colors.green : Colors.grey,
                          ),
                          Text(
                            "${isLoading ? "Disponível" : "Indisponível"} para viagens",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        value: isLoading, 
                        onChanged: (value) {
                          setState(() {
                            isLoading = value;
                          });
                        }
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Próxima viagem",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                TripCard(
                  fazenda: 'Fazenda Filomena',
                  status: 'Pendente',
                  origem: 'AGT - Administração Geral Tributária',
                  destino: 'TIS TECH ANGOLA',
                  quantidade: '320kg/cx',
                  produto: 'Tomate',
                  oferta: '88.000kz',
                  onIniciar: () => showFollwoUp(context)       
                ),
                SizedBox(height: 20),
                Column(
                  spacing: 15,
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 231, 231, 231),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: .center,
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "10",
                            style: TextStyle(
                              fontSize: 20,
                              color: REGISTheme.surface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero
                            ),
                            child: Text(
                              "Todas as viagens",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100,
                          width: 175,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 231, 231, 231),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: .center,
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                "11",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: REGISTheme.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => 
                                  //     const MapScreen(
                                  //       destino: gmaps.LatLng(-8.7922, 13.2205), // Ilha de Luanda 
                                  //     )),
                                  // )
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero
                                ),
                                child: Text(
                                  "Viagens confirmadas",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 175,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 231, 231, 231),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: .center,
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                "12",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: REGISTheme.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero
                                ),
                                child: Text(
                                  "Viagens concluídas",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
