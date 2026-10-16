import 'package:app_test_e2e/domain/entities/user.dart';

class UserModel {
  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );

  final String id;
  final String name;
  final String email;

  User toEntity() => User(id: id, name: name, email: email);
}
