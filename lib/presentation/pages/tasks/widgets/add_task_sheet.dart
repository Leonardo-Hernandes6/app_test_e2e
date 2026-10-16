import 'package:app_test_e2e/core/utils/failure_message.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_keys.dart';
import 'package:app_test_e2e/presentation/providers/tasks/tasks_provider.dart';
import 'package:app_test_e2e/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const AddTaskSheet(key: AddTaskKeys.sheet),
  );

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _title = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final failure = await ref
        .read(tasksNotifierProvider.notifier)
        .add(_title.text);
    if (!mounted) return;

    if (failure == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nova tarefa', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            key: AddTaskKeys.title,
            controller: _title,
            autofocus: true,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'O que precisa ser feito?',
              errorText: _error,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            key: AddTaskKeys.save,
            label: 'Adicionar',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
