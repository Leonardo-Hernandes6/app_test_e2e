import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';

class AddTaskUsecase {
  const AddTaskUsecase(this._repository);

  static const maxTitleLength = 80;

  final TaskRepository _repository;

  Future<Result<Task>> call(String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return const Err(ValidationFailure('Dê um título para a tarefa.'));
    }
    if (normalized.length > maxTitleLength) {
      return const Err(
        ValidationFailure(
          'O título deve ter no máximo $maxTitleLength caracteres.',
        ),
      );
    }
    return _repository.create(normalized);
  }
}
