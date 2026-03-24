enum TripStatus { pending, inProgress, completed, cancelled }
enum TripType { passenger, cargo, mixed }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  final double rating;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.rating = 5.0,
  });
}

class Trip {
  final String id;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final TripStatus status;
  final TripType type;
  final double price;
  final int seats;
  final int availableSeats;
  final User driver;
  final List<User> passengers;
  final String? notes;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.status,
    required this.type,
    required this.price,
    required this.seats,
    required this.availableSeats,
    required this.driver,
    this.passengers = const [],
    this.notes,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String type;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.type = 'info',
  });
}

final User sampleDriver = User(
  id: '1',
  name: 'João Calúnde',
  email: 'joao.calunde@tis.ao',
  phone: '+244 923 456 789',
  role: 'driver',
  rating: 4.8,
);

final User samplePassenger1 = User(
  id: '2',
  name: 'Ana Martins',
  email: 'ana.martins@tis.ao',
  phone: '+244 912 345 678',
  role: 'passenger',
  rating: 4.9,
);

final User samplePassenger2 = User(
  id: '3',
  name: 'José Mário',
  email: 'jose.mario@tis.ao',
  phone: '+244 934 567 890',
  role: 'passenger',
  rating: 4.7,
);

final User currentUser = User(
  id: '4',
  name: 'Cameron Williamson',
  email: 'cameron.w@tis.ao',
  phone: '+244 945 678 901',
  role: 'driver',
  rating: 4.6,
);

final List<Trip> sampleTrips = [
  Trip(
    id: 't1',
    origin: 'Luanda Norte',
    destination: 'Talatona',
    departureTime: DateTime.now().add(const Duration(hours: 2)),
    status: TripStatus.pending,
    type: TripType.passenger,
    price: 2500,
    seats: 4,
    availableSeats: 2,
    driver: sampleDriver,
    passengers: [samplePassenger1, samplePassenger2],
  ),
  Trip(
    id: 't2',
    origin: 'Viana',
    destination: 'Centro Luanda',
    departureTime: DateTime.now().add(const Duration(hours: 5)),
    status: TripStatus.pending,
    type: TripType.mixed,
    price: 3500,
    seats: 6,
    availableSeats: 3,
    driver: sampleDriver,
    passengers: [samplePassenger1],
  ),
  Trip(
    id: 't3',
    origin: 'Benfica',
    destination: 'Aeroporto',
    departureTime: DateTime.now().subtract(const Duration(hours: 3)),
    status: TripStatus.completed,
    type: TripType.passenger,
    price: 4000,
    seats: 4,
    availableSeats: 0,
    driver: sampleDriver,
    passengers: [samplePassenger1, samplePassenger2],
  ),
  Trip(
    id: 't4',
    origin: 'Miramar',
    destination: 'Camama',
    departureTime: DateTime.now().subtract(const Duration(days: 1)),
    status: TripStatus.completed,
    type: TripType.cargo,
    price: 6000,
    seats: 2,
    availableSeats: 0,
    driver: sampleDriver,
    passengers: [samplePassenger1],
  ),
];

final List<Notification> sampleNotifications = [
  Notification(
    id: 'n1',
    title: 'Nova Solicitação de Viagem',
    message: 'Ana Martins solicitou uma viagem para Talatona às 14:30',
    time: DateTime.now().subtract(const Duration(minutes: 10)),
    type: 'info',
  ),
  Notification(
    id: 'n2',
    title: 'Viagem Confirmada',
    message: 'A sua viagem para o Aeroporto foi confirmada com sucesso.',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: true,
    type: 'success',
  ),
  Notification(
    id: 'n3',
    title: 'Lembrete de Viagem',
    message: 'Tem uma viagem para Viana amanhã às 08:00.',
    time: DateTime.now().subtract(const Duration(hours: 3)),
    type: 'warning',
  ),
  Notification(
    id: 'n4',
    title: 'Notificação de Pagamento',
    message: 'Recebeu 2.500 Kz pela viagem Luanda-Talatona.',
    time: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: true,
    type: 'success',
  ),
];
