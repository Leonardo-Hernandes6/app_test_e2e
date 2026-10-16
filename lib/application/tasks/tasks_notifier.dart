import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/presentation/providers/tasks/tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final result = await ref.read(getTasksUsecaseProvider)();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Failure?> add(String title) async {
    final result = await ref.read(addTaskUsecaseProvider)(title);
    if (!ref.mounted) return null;

    switch (result) {
      case Ok(value: final task):
        _emit([..._current, task]);
        return null;
      case Err(:final failure):
        return failure;
    }
  }

  Future<Failure?> toggle(Task task) async {
    _replace(task.copyWith(done: !task.done));

    final result = await ref.read(toggleTaskUsecaseProvider)(task);
    if (!ref.mounted) return null;

    switch (result) {
      case Ok(value: final updated):
        _replace(updated);
        return null;
      case Err(:final failure):
        _replace(task);
        return failure;
    }
  }

  Future<Failure?> delete(Task task) async {
    _emit([
      for (final item in _current)
        if (item.id != task.id) item,
    ]);

    final result = await ref.read(deleteTaskUsecaseProvider)(task.id);
    if (!ref.mounted) return null;

    switch (result) {
      case Ok():
        return null;
      case Err(:final failure):
        _emit(
          [..._current, task]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        );
        return failure;
    }
  }

  List<Task> get _current => state.value ?? const [];

  void _emit(List<Task> tasks) => state = AsyncData(tasks);

  void _replace(Task task) =>
      _emit([for (final item in _current) item.id == task.id ? task : item]);
}
