import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';
import 'package:app_test_e2e/domain/usecases/add_task_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository repository;
  late AddTaskUsecase addTask;

  setUp(() {
    repository = _MockTaskRepository();
    addTask = AddTaskUsecase(repository);
  });

  test(
    'AddTaskUsecase | remove espaços do título antes de criar a tarefa',
    () async {
      final task = buildTask(title: 'Ensaiar');
      when(
        () => repository.create('Ensaiar'),
      ).thenAnswer((_) async => Ok(task));

      final result = await addTask('  Ensaiar  ');

      expect(result, isA<Ok<Task>>().having((ok) => ok.value, 'value', task));
    },
  );

  test(
    'AddTaskUsecase | recusa título vazio sem chamar o repositório',
    () async {
      final result = await addTask('   ');

      expect(
        result,
        isA<Err<Task>>().having(
          (err) => err.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      verifyZeroInteractions(repository);
    },
  );

  test('AddTaskUsecase | recusa título maior que o limite', () async {
    final result = await addTask('x' * (AddTaskUsecase.maxTitleLength + 1));

    expect(result, isA<Err<Task>>());
    verifyZeroInteractions(repository);
  });
}
