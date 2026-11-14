import 'package:flutter/material.dart';

class DueDateButton extends StatelessWidget {
  const DueDateButton({
    super.key,
    required this.dueDate,
    required this.onPick,
    required this.onRemove,
  });

  final DateTime? dueDate;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final date = dueDate;
    return Row(
      children: [
        Flexible(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_today_outlined, size: 17),
            label: Text(
              date == null
                  ? 'Add due date'
                  : MaterialLocalizations.of(context).formatMediumDate(date),
            ),
          ),
        ),
        if (date != null)
          IconButton(
            tooltip: 'Remove due date',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    );
  }
}
