import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';

class GetTasksUsecase {
  const GetTasksUsecase(this._repository);

  final TaskRepository _repository;

  Future<Result<List<Task>>> call() => _repository.fetchAll();
}
