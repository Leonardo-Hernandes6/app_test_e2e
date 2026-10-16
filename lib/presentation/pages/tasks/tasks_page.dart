import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/failure_message.dart';
import 'package:app_test_e2e/domain/entities/task.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:app_test_e2e/presentation/pages/tasks/widgets/add_task_sheet.dart';
import 'package:app_test_e2e/presentation/pages/tasks/widgets/task_list.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:app_test_e2e/presentation/providers/tasks/tasks_provider.dart';
import 'package:app_test_e2e/presentation/widgets/app_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final tasks = ref.watch(tasksNotifierProvider);
    final controller = ref.read(tasksNotifierProvider.notifier);

    void report(Failure? failure) {
      if (failure == null || !context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message)));
    }

    Future<void> toggle(Task task) async =>
        report(await controller.toggle(task));
    Future<void> delete(Task task) async =>
        report(await controller.delete(task));

    return Scaffold(
      key: TasksKeys.page,
      appBar: AppBar(
        title: Text(
          user == null ? 'Minhas tarefas' : 'Olá, ${user.firstName}',
          key: TasksKeys.greeting,
        ),
        actions: [
          IconButton(
            key: TasksKeys.logout,
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: TasksKeys.addButton,
        onPressed: () => AddTaskSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.reload,
        child: switch (tasks) {
          AsyncData(value: final items) when items.isEmpty => const _Scrollable(
            child: AppMessageView(
              key: TasksKeys.empty,
              icon: Icons.checklist,
              title: 'Nenhuma tarefa por aqui',
              description: 'Toque em "Nova tarefa" para começar.',
            ),
          ),
          AsyncData(value: final items) => TaskList(
            tasks: items,
            onToggle: toggle,
            onDelete: delete,
          ),
          AsyncError(:final error) => _Scrollable(
            child: AppMessageView(
              key: TasksKeys.error,
              icon: Icons.cloud_off,
              title: 'Não foi possível carregar suas tarefas',
              description: error is Failure ? error.message : null,
              actionLabel: 'Tentar novamente',
              onAction: controller.reload,
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}
