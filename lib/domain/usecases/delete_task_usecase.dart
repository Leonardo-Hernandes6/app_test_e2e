import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';

class DeleteTaskUsecase {
  const DeleteTaskUsecase(this._repository);

  final TaskRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
