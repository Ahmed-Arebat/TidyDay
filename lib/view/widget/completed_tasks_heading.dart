import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';
import 'task_section_label.dart';

class CompletedTasksHeading extends StatelessWidget {
  const CompletedTasksHeading({
    super.key,
    required this.count,
    required this.expanded,
    required this.onPressed,
  });

  final int count;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      expanded: expanded,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: TaskSectionLabel(title: 'Completed', count: count),
              ),
              AnimatedRotation(
                turns: expanded ? .5 : 0,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
