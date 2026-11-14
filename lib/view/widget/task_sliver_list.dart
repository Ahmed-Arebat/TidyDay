import 'package:flutter/material.dart';

import '../../data/model/task.dart';
import 'task_row.dart';

class TaskSliverList extends StatelessWidget {
  const TaskSliverList({
    super.key,
    required this.tasks,
    required this.today,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Task> tasks;
  final DateTime today;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onToggle;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            key: ValueKey(task.id),
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskRow(
              task: task,
              today: today,
              onEdit: () => onEdit(task),
              onToggle: () => onToggle(task),
            ),
          );
        },
      ),
    );
  }
}
