import 'package:app_test_e2e/application/tasks/tasks_notifier.dart';
import 'package:app_test_e2e/core/providers/dio_provider.dart';
import 'package:app_test_e2e/data/datasources/task_remote_datasource.dart';
import 'package:app_test_e2e/data/repositories/task_repository_impl.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';
import 'package:app_test_e2e/domain/usecases/add_task_usecase.dart';
import 'package:app_test_e2e/domain/usecases/delete_task_usecase.dart';
import 'package:app_test_e2e/domain/usecases/get_tasks_usecase.dart';
import 'package:app_test_e2e/domain/usecases/toggle_task_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskRemoteDatasourceProvider = Provider<TaskRemoteDatasource>(
  (ref) => TaskRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskRemoteDatasourceProvider)),
);

final getTasksUsecaseProvider = Provider(
  (ref) => GetTasksUsecase(ref.watch(taskRepositoryProvider)),
);

final addTaskUsecaseProvider = Provider(
  (ref) => AddTaskUsecase(ref.watch(taskRepositoryProvider)),
);

final toggleTaskUsecaseProvider = Provider(
  (ref) => ToggleTaskUsecase(ref.watch(taskRepositoryProvider)),
);

final deleteTaskUsecaseProvider = Provider(
  (ref) => DeleteTaskUsecase(ref.watch(taskRepositoryProvider)),
);

final tasksNotifierProvider =
    AsyncNotifierProvider.autoDispose<TasksNotifier, List<Task>>(
      TasksNotifier.new,
    );
