class Transport {
  final String? id;
  final String? status;
  final String? delivered_at;
  final String? start_at;
  final Farm farm;
  final Order order;
  final Vehicle vehicle;

  Transport({
    required this.id,
    required this.delivered_at,
    required this.start_at,
    required this.status,
    required this.farm,
    required this.order,
    required this.vehicle,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json["id"] as String? ?? "",
      status: json["status"] as String? ?? "inválido",
      start_at: json["start_at"],
      delivered_at: json["delivered_at"],
      farm: Farm.fromJson((json['farm'] as Map<String, dynamic>?) ?? {}),
      order: Order.fromJson((json['order'] as Map<String, dynamic>?) ?? {}),
      vehicle: Vehicle.fromJson((json['vehicle'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class Farm {
  final String? id;
  final String? name;
  final String? phone;
  final String? province;
  final String? adress;
  final String? profile;

  Farm({
    required this.id,
    required this.adress,
    required this.name,
    required this.phone,
    required this.profile,
    required this.province,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json["id"] as String? ?? "",
      name: json["name"] as String? ?? "Sem nome",
      phone: json["phone"] as String? ?? "Sem telefone",
      province: json["province"] as String? ?? "Sem província",
      adress: json["adress"] as String? ?? "Sem endereço",
      profile: json["profile"] as String? ?? "",
    );
  }
}

class Order {
  final String? productId;
  final String? productName;
  final String? price;
  final String? photo;
  final String? qtd;
  final String? earning;
  final String? delivery_adress;

  Order({
    required this.delivery_adress,
    required this.earning,
    required this.photo,
    required this.price,
    required this.productId,
    required this.productName,
    required this.qtd,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      productId: json["product_id"] as String? ?? "",
      delivery_adress: json["delivery_adress"] as String? ?? "Sem endereço",
      productName: json["productName"] as String? ?? "Sem nome",
      earning: json["earning"] as String? ?? "Valor Inválido",
      photo: json["photo"] as String? ?? "",
      price: json["price"] as String? ?? "Preço ionválido",
      qtd: json["qtd"] as String? ?? "qtd inválida",
    );
  }
}

class Vehicle {
  final String? id;
  final String? brand;
  final String? plate;
  final String? type;
  final String? capacity;
  final String? photo;

  Vehicle({
    required this.brand,
    required this.capacity,
    required this.id,
    required this.photo,
    required this.plate,
    required this.type,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"] as String? ?? "",
      brand: json["brand"] as String? ?? "Sem marca",
      plate: json["plate"] as String? ?? "Sem placa",
      capacity: json["capacity"] as String? ?? "sem capacidade",
      photo: json["photo"] as String? ?? "",
      type: json["type"] as String? ?? "tipo inválido",
    );
  }
}
