import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/domain/entities/user.dart';

const ana = User(id: 'u1', name: 'Ana Souza', email: 'ana@demo.com');

Task buildTask({
  String id = 't1',
  String title = 'Ensaiar',
  bool done = false,
}) => Task(
  id: id,
  title: title,
  done: done,
  createdAt: DateTime.utc(2026, 10, 16, 9, int.parse(id.substring(1))),
);
