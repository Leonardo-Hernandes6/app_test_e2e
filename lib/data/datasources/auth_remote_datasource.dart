import 'package:app_test_e2e/data/models/session_model.dart';
import 'package:app_test_e2e/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRemoteDatasource {
  Future<SessionModel> login({required String email, required String password});

  Future<SessionModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> currentUser();

  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return SessionModel.fromJson(response.data!);
  }

  @override
  Future<SessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return SessionModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> currentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() => _dio.post<void>('/auth/logout');
}
