import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:flutter/material.dart';

class TaskSummary extends StatelessWidget {
  const TaskSummary({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = tasks.where((task) => task.done).length;
    final total = tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$done de $total concluídas',
          key: TasksKeys.summary,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
