import 'package:flutter/widgets.dart';

abstract final class TasksKeys {
  static const page = Key('tasks.page');
  static const greeting = Key('tasks.greeting');
  static const logout = Key('tasks.logout');
  static const list = Key('tasks.list');
  static const summary = Key('tasks.summary');
  static const empty = Key('tasks.empty');
  static const error = Key('tasks.error');
  static const addButton = Key('tasks.addButton');

  static Key tile(String id) => Key('tasks.tile.$id');
  static Key checkbox(String id) => Key('tasks.checkbox.$id');
  static Key delete(String id) => Key('tasks.delete.$id');
}

abstract final class AddTaskKeys {
  static const sheet = Key('addTask.sheet');
  static const title = Key('addTask.title');
  static const save = Key('addTask.save');
  static const error = Key('addTask.error');
}
