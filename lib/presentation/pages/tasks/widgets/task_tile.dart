import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.outlined(
      key: TasksKeys.tile(task.id),
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onToggle,
        leading: Checkbox(
          key: TasksKeys.checkbox(task.id),
          value: task.done,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: task.done
              ? theme.textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        trailing: IconButton(
          key: TasksKeys.delete(task.id),
          tooltip: 'Excluir tarefa',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
