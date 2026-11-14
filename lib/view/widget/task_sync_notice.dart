import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class TaskSyncNotice extends StatelessWidget {
  const TaskSyncNotice({super.key, required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(
            pending ? Icons.sync_rounded : Icons.cloud_outlined,
            color: AppColors.muted,
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              pending ? 'Sync pending' : 'Showing saved tasks',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
