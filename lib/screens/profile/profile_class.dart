class UserModel {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? profile;
  final String province;
  final String adress;
  final String balance;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.province,
    required this.adress,
    required this.balance,
    this.profile,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? province,
    String? adress,
    String? bio,
    String? profile,
    String? balance
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profile: profile ?? this.profile,
      province: province ?? "",
      adress: adress ?? "",
      balance: balance ?? this.balance
    );
  }
}
