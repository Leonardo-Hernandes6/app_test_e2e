import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';

class ToggleTaskUsecase {
  const ToggleTaskUsecase(this._repository);

  final TaskRepository _repository;

  Future<Result<Task>> call(Task task) =>
      _repository.setDone(task.id, done: !task.done);
}
