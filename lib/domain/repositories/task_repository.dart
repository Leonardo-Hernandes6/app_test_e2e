import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';

abstract interface class TaskRepository {
  Future<Result<List<Task>>> fetchAll();

  Future<Result<Task>> create(String title);

  Future<Result<Task>> setDone(String id, {required bool done});

  Future<Result<void>> delete(String id);
}
