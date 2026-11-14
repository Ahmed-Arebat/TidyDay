import 'package:flutter/material.dart';

import '../../data/model/task.dart';
import '../action/confirm_task_deletion.dart';
import 'due_date_button.dart';

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key, this.task, required this.onSave, this.onDelete});

  final Task? task;
  final ValueChanged<TaskDraft> onSave;
  final VoidCallback? onDelete;

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.task?.draft.title);
  late final _notes = TextEditingController(text: widget.task?.draft.notes);
  late DateTime? _dueDate = widget.task?.draft.dueDate;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Due date',
    );
    if (date != null && mounted) setState(() => _dueDate = date);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    widget.onSave(
      TaskDraft(
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        dueDate: _dueDate,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    FocusScope.of(context).unfocus();
    final confirmed = await confirmTaskDeletion(context);
    if (confirmed && mounted) widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        editing ? 'Edit task' : 'New task',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  validator: TaskDraft.validateTitle,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  validator: TaskDraft.validateNotes,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DueDateButton(
                  dueDate: _dueDate,
                  onPick: _pickDate,
                  onRemove: () => setState(() => _dueDate = null),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (widget.onDelete != null) ...[
                      IconButton.outlined(
                        tooltip: 'Delete task',
                        onPressed: _confirmDelete,
                        color: theme.colorScheme.error,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(editing ? 'Save changes' : 'Add task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
