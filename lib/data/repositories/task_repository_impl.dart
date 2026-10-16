import 'package:app_test_e2e/core/utils/error_handler.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/data/datasources/task_remote_datasource.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TaskRemoteDatasource _remote;

  @override
  Future<Result<List<Task>>> fetchAll() => guardRequest(
    () async => [
      for (final model in await _remote.fetchAll()) model.toEntity(),
    ],
  );

  @override
  Future<Result<Task>> create(String title) =>
      guardRequest(() async => (await _remote.create(title)).toEntity());

  @override
  Future<Result<Task>> setDone(String id, {required bool done}) => guardRequest(
    () async => (await _remote.update(id, done: done)).toEntity(),
  );

  @override
  Future<Result<void>> delete(String id) =>
      guardRequest(() => _remote.delete(id));
}
