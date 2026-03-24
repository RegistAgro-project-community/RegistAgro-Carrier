class DriverRoutes {
  final String id;
  final String origin;
  final String destination;
  final String price;

  DriverRoutes({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,

  });
}

final List<DriverRoutes> sampleDriverRoutes = [
  DriverRoutes(
    id: 'n1',
    origin: 'Kuanza Sul',
    destination: 'Launda',
    price: '50.000kz',
  ),
  DriverRoutes(
    id: 'n2',
    origin: 'Viagem Confirmada',
    destination: 'A sua viagem para o Aeroporto foi confirmada com sucesso.',
    price: '150.000kz',
  ),
  DriverRoutes(
    id: 'n3',
    origin: 'Lembrete de Viagem',
    destination: 'Tem uma viagem para Viana amanhã às 08:00.',
    price: '38.000kz',
  ),
  DriverRoutes(
    id: 'n4',
    origin: 'Notificação de Pagamento',
    destination: 'Recebeu 2.500 Kz pela viagem Luanda-Talatona.',
    price: '188.00kz',
  ),
];