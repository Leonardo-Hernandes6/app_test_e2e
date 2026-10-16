import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:app_test_e2e/presentation/pages/tasks/widgets/task_summary.dart';
import 'package:app_test_e2e/presentation/pages/tasks/widgets/task_tile.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: TasksKeys.list,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: tasks.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 20 : 8),
      itemBuilder: (_, index) {
        if (index == 0) return TaskSummary(tasks: tasks);
        final task = tasks[index - 1];
        return TaskTile(
          task: task,
          onToggle: () => onToggle(task),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}
