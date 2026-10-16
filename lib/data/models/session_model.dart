import 'package:app_test_e2e/data/models/user_model.dart';

class SessionModel {
  const SessionModel({required this.token, required this.user});

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    token: json['token'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String token;
  final UserModel user;
}
