class VehicleModel {
  final String? id;
  final String? brand;
  final String? plate;
  final String? type;
  final String? capacity;
  final String? photo;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.capacity,
    required this.photo,
    required this.plate,
    required this.type,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json["id"] as String? ?? "",
      brand: json["brand"] as String? ?? "sem marca",
      capacity: json["capacity"] as String? ?? "capacidade inválida",
      photo: json["photo"] as String? ?? "",
      plate: json["plate"] as String? ?? "placa inválida",
      type: json["type"] as String? ?? "tipo inválido",
    );
  }
}
