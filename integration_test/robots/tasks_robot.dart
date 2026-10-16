import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:app_test_e2e/presentation/pages/tasks/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'robot.dart';

class TasksRobot extends Robot {
  const TasksRobot(super.tester);

  Future<void> expectVisible({required String greeting}) async {
    await waitFor(find.byKey(TasksKeys.page));
    expect(_textOf(TasksKeys.greeting), greeting);
  }

  Future<void> expectEmpty() => waitFor(find.byKey(TasksKeys.empty));

  Future<void> addTask(String title) async {
    await tap(find.byKey(TasksKeys.addButton));
    await waitFor(find.byKey(AddTaskKeys.sheet));
    await type(AddTaskKeys.title, title);
    await tap(find.byKey(AddTaskKeys.save));
    await waitUntilGone(find.byKey(AddTaskKeys.sheet));
    await waitFor(_tile(title));
  }

  Future<void> toggleTask(String title) =>
      tap(find.descendant(of: _tile(title), matching: find.byType(Checkbox)));

  Future<void> deleteTask(String title) async {
    await tap(
      find.descendant(
        of: _tile(title),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await waitUntilGone(_tile(title));
  }

  Future<void> expectTask(String title, {required bool done}) async {
    await waitFor(_tile(title));
    final checkbox = tester.widget<Checkbox>(
      find.descendant(of: _tile(title), matching: find.byType(Checkbox)),
    );
    expect(checkbox.value, done, reason: '"$title" done state');
  }

  void expectNoTask(String title) => expect(_tile(title), findsNothing);

  void expectSummary(String text) => expect(_textOf(TasksKeys.summary), text);

  Future<void> logout() => tap(find.byKey(TasksKeys.logout));

  String? _textOf(Key key) => tester.widget<Text>(find.byKey(key)).data;

  Finder _tile(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(TaskTile));
}
