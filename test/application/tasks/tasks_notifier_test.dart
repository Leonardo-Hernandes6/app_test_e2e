import 'dart:async';

import 'package:app_test_e2e/application/tasks/tasks_notifier.dart';
import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';
import 'package:app_test_e2e/presentation/providers/tasks/tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository repository;
  late ProviderContainer container;

  final first = buildTask(id: 't1', title: 'Ensaiar');
  final second = buildTask(id: 't2', title: 'Apresentar');

  setUp(() {
    repository = _MockTaskRepository();
    container = ProviderContainer.test(
      overrides: [taskRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
  });

  Future<List<Task>> start() {
    container.listen(tasksNotifierProvider, (_, _) {});
    return container.read(tasksNotifierProvider.future);
  }

  TasksNotifier controller() => container.read(tasksNotifierProvider.notifier);

  List<Task> currentTasks() => container.read(tasksNotifierProvider).value!;

  Future<void> loadWith(List<Task> tasks) async {
    when(repository.fetchAll).thenAnswer((_) async => Ok(tasks));
    await start();
  }

  test('TasksNotifier | carregar: expõe a falha quando a API falha', () async {
    when(
      repository.fetchAll,
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    await expectLater(start(), throwsA(const NetworkFailure()));
    expect(container.read(tasksNotifierProvider).error, const NetworkFailure());
  });

  test(
    'TasksNotifier | adicionar: inclui a tarefa criada no fim da lista',
    () async {
      await loadWith([first]);
      when(
        () => repository.create('Apresentar'),
      ).thenAnswer((_) async => Ok(second));

      final failure = await controller().add('Apresentar');

      expect(failure, isNull);
      expect(currentTasks(), [first, second]);
    },
  );

  test(
    'TasksNotifier | concluir: atualiza a lista antes da resposta da API',
    () async {
      await loadWith([first]);
      final response = Completer<Result<Task>>();
      when(
        () => repository.setDone('t1', done: true),
      ).thenAnswer((_) => response.future);

      final pending = controller().toggle(first);
      expect(currentTasks().single.done, isTrue);

      response.complete(Ok(first.copyWith(done: true)));
      expect(await pending, isNull);
      expect(currentTasks().single.done, isTrue);
    },
  );

  test(
    'TasksNotifier | concluir: desfaz a mudança quando a API falha',
    () async {
      await loadWith([first]);
      when(
        () => repository.setDone('t1', done: true),
      ).thenAnswer((_) async => const Err(ServerFailure(500)));

      final failure = await controller().toggle(first);

      expect(failure, const ServerFailure(500));
      expect(currentTasks().single.done, isFalse);
    },
  );

  test(
    'TasksNotifier | excluir: devolve a tarefa à posição original quando a API falha',
    () async {
      await loadWith([first, second]);
      when(
        () => repository.delete('t1'),
      ).thenAnswer((_) async => const Err(NetworkFailure()));

      final failure = await controller().delete(first);

      expect(failure, const NetworkFailure());
      expect(currentTasks(), [first, second]);
    },
  );
}
