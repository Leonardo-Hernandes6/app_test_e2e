import 'package:app_test_e2e/data/models/task_model.dart';
import 'package:dio/dio.dart';

abstract interface class TaskRemoteDatasource {
  Future<List<TaskModel>> fetchAll();

  Future<TaskModel> create(String title);

  Future<TaskModel> update(String id, {required bool done});

  Future<void> delete(String id);
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  const TaskRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskModel>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/tasks/');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .toList();
  }

  @override
  Future<TaskModel> create(String title) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tasks/',
      data: {'title': title},
    );
    return TaskModel.fromJson(response.data!);
  }

  @override
  Future<TaskModel> update(String id, {required bool done}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/tasks/$id',
      data: {'done': done},
    );
    return TaskModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(String id) => _dio.delete<void>('/tasks/$id');
}
