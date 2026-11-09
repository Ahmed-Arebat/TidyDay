import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';
import '../../data/model/task.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.today,
    required this.onEdit,
    required this.onToggle,
  });

  final Task task;
  final DateTime today;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final due = task.draft.dueDate;
    final overdue = due != null && due.isBefore(today) && !task.completed;
    final dateColor = overdue ? theme.colorScheme.error : AppColors.muted;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final title = task.draft.title;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Semantics(
              container: true,
              label: task.completed ? 'Reopen $title' : 'Mark $title complete',
              checked: task.completed,
              child: IconButton(
                onPressed: onToggle,
                icon: AnimatedSwitcher(
                  duration: duration,
                  child: Icon(
                    task.completed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(task.completed),
                    color: task.completed ? AppColors.primary : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              container: true,
              button: true,
              child: InkWell(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 12, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleMedium?.copyWith(
                                color: task.completed
                                    ? AppColors.muted
                                    : AppColors.ink,
                                fontWeight: FontWeight.w600,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.draft.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                task.draft.notes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                            if (due != null) ...[
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: dateColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _dueLabel(context, due, overdue),
                                      style: text.labelMedium?.copyWith(
                                        color: dateColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 19,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dueLabel(BuildContext context, DateTime due, bool overdue) {
    final date = MaterialLocalizations.of(context).formatMediumDate(due);
    if (overdue) return 'Overdue · $date';
    if (DateUtils.isSameDay(due, today)) return 'Today';
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    if (DateUtils.isSameDay(due, tomorrow)) return 'Tomorrow';
    return date;
  }
}
