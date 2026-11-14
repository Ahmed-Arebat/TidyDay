import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class TaskOverview extends StatelessWidget {
  const TaskOverview({
    super.key,
    required this.today,
    required this.total,
    required this.completed,
    required this.showProgress,
  });

  final DateTime today;
  final int total;
  final int completed;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final date = MaterialLocalizations.of(context).formatFullDate(today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: text.labelLarge?.copyWith(color: AppColors.muted)),
        const SizedBox(height: 5),
        Text(
          'My Tasks',
          style: text.displaySmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        if (showProgress) ...[
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Your progress',
                        style: text.labelLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$completed of $total complete',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: total == 0 ? 0 : completed / total),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: AppColors.primary.withValues(alpha: .12),
                      color: AppColors.primary,
                      semanticsLabel: 'Task completion',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
