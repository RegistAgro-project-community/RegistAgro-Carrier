import 'package:flutter/material.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class TripCard extends StatelessWidget {
  final String fazenda;
  final String status;
  final String origem;
  final String destino;
  final String quantidade;
  final String produto;
  final String oferta;
  final VoidCallback onIniciar;

  const TripCard({
    super.key,
    required this.fazenda,
    required this.status,
    required this.origem,
    required this.destino,
    required this.quantidade,
    required this.produto,
    required this.oferta,
    required this.onIniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 335,
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 231, 231, 231)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 214, 213, 213),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  Text(
                    fazenda,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: REGISTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color.fromARGB(255, 223, 222, 222),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: REGISTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  Column(
                    spacing: 5,
                    children: List.generate(7, (_) => Container(
                      height: 5,
                      width: 1,
                      color: Colors.grey,
                    )),
                  ),
                  const Icon(Icons.place_outlined, size: 20, color: Colors.grey),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                spacing: 30,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LocalInfo(label: 'De onde vais sair ?', valor: origem),
                  _LocalInfo(label: 'Para onde vamos ?', valor: destino),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metrica(label: 'Quantidade', valor: quantidade),
              _Metrica(label: 'Produto', valor: produto),
              _Metrica(label: 'Oferta', valor: oferta),
            ],
          ),
          ElevatedButton(
            onPressed: onIniciar,
            style: ElevatedButton.styleFrom(
              backgroundColor: REGISTheme.surface,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Iniciar viagem'),
          ),
        ],
      ),
    );
  }
}

class _LocalInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _LocalInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(
            fontSize: 13, 
            color: Colors.grey, 
            fontWeight: FontWeight.w400
          )
        ),
        Text(
          valor, 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(
            fontSize: 14, 
            color: Colors.black, 
            fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final String valor;
  const _Metrica({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 3,
          children: [
            const Icon(Icons.circle, color: Colors.grey, size: 8),
            Text(
              label, 
              style: const TextStyle(
                color: Colors.grey, 
                fontWeight: FontWeight.normal
              )
            ),
          ],
        ),
        Text(
          valor, 
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 16, 
            fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}