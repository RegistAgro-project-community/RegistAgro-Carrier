class VehicleModel {
  final String id;
  final String brand;
  final String model;
  final String color;
  final String typology;
  final String? plate;
  final String? year;
  final String? capacity;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.typology,
    this.plate,
    this.year,
    this.capacity,
  });
}