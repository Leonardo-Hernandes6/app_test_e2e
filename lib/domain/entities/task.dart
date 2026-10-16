import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  Task copyWith({String? title, bool? done}) => Task(
    id: id,
    title: title ?? this.title,
    done: done ?? this.done,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, title, done, createdAt];
}
