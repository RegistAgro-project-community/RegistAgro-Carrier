class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? profile;
  final String? province;
  final String? adress;
  final String balance;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.province,
    this.adress,
    required this.balance,
    this.profile,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? province,
    String? adress,
    String? bio,
    String? profile,
    String? balance,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profile: profile ?? this.profile,
      province: province ?? this.province,
      adress: adress ?? this.adress,
      balance: balance ?? this.balance,
    );
  }
}
