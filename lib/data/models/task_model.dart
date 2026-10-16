import 'package:app_test_e2e/domain/entities/task.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String,
    title: json['title'] as String,
    done: json['done'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  Task toEntity() =>
      Task(id: id, title: title, done: done, createdAt: createdAt);
}
