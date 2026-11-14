import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class TaskSectionLabel extends StatelessWidget {
  const TaskSectionLabel({super.key, required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: text.labelSmall?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
