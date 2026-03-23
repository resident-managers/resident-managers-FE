class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).cast<String>(),
    );
  }

  UserModel copyWith({String? name, String? email, List<String>? roles}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
    );
  }
}
