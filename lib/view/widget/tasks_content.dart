import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controller/tasks_bloc.dart';
import '../../core/constant/app_theme.dart';
import '../../data/model/task.dart';
import 'account_avatar.dart';
import 'brand_mark.dart';
import 'completed_tasks_heading.dart';
import 'task_list_message.dart';
import 'task_loading_skeleton.dart';
import 'task_overview.dart';
import 'task_section_label.dart';
import 'task_sliver_list.dart';
import 'task_sync_notice.dart';

class TasksContent extends StatelessWidget {
  const TasksContent({
    super.key,
    required this.user,
    required this.state,
    required this.authBusy,
    required this.showCompleted,
    required this.onAccount,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
    required this.onRetryLoad,
    required this.onToggleCompleted,
  });

  final User user;
  final TasksState state;
  final bool authBusy;
  final bool showCompleted;
  final VoidCallback onAccount;
  final VoidCallback onAdd;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onToggle;
  final VoidCallback onRetryLoad;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final open = state.tasks.where((task) => !task.completed).toList();
    final completed = state.tasks.where((task) => task.completed).toList();
    final ready = !state.loading && !state.loadFailed;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              _TasksHeader(
                user: user,
                accountEnabled: !authBusy,
                onAccount: onAccount,
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        if (state.loading && state.tasks.isEmpty)
                          const SliverToBoxAdapter(child: TaskLoadingSkeleton())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
                            sliver: SliverToBoxAdapter(
                              child: TaskOverview(
                                today: today,
                                total: state.tasks.length,
                                completed: completed.length,
                                showProgress: ready || state.tasks.isNotEmpty,
                              ),
                            ),
                          ),
                        if (state.loadFailed)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            sliver: SliverToBoxAdapter(
                              child: TaskListMessage(
                                icon: Icons.cloud_off_outlined,
                                title: 'Could not load tasks',
                                detail: 'Check your connection and try again.',
                                action: TextButton(
                                  onPressed: onRetryLoad,
                                  child: const Text('Retry'),
                                ),
                              ),
                            ),
                          ),
                        if (ready &&
                            (state.hasPendingChanges || state.fromCache))
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            sliver: SliverToBoxAdapter(
                              child: TaskSyncNotice(
                                pending: state.hasPendingChanges,
                              ),
                            ),
                          ),
                        if (ready && state.tasks.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverToBoxAdapter(
                              child: state.fromCache
                                  ? const TaskListMessage(
                                      icon: Icons.cloud_outlined,
                                      title: 'Waiting for your tasks',
                                      detail:
                                          'Your list will refresh when you connect.',
                                    )
                                  : const TaskListMessage(
                                      icon: Icons.checklist_rounded,
                                      title: 'A fresh start',
                                      detail:
                                          'Add a task to start planning your day.',
                                    ),
                            ),
                          ),
                        if (open.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            sliver: SliverToBoxAdapter(
                              child: TaskSectionLabel(
                                title: 'Open',
                                count: open.length,
                              ),
                            ),
                          ),
                          TaskSliverList(
                            tasks: open,
                            today: today,
                            onEdit: onEdit,
                            onToggle: onToggle,
                          ),
                        ],
                        if (completed.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverToBoxAdapter(
                              child: CompletedTasksHeading(
                                count: completed.length,
                                expanded: showCompleted,
                                onPressed: onToggleCompleted,
                              ),
                            ),
                          ),
                          if (showCompleted)
                            TaskSliverList(
                              tasks: completed,
                              today: today,
                              onEdit: onEdit,
                              onToggle: onToggle,
                            ),
                        ],
                        const SliverToBoxAdapter(child: SizedBox(height: 88)),
                      ],
                    ),
                    if (ready)
                      Positioned(
                        bottom: 16,
                        right: 20,
                        left: 20,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton.extended(
                            onPressed: onAdd,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add task'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader({
    required this.user,
    required this.accountEnabled,
    required this.onAccount,
  });

  final User user;
  final bool accountEnabled;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 14, 5),
      child: Row(
        children: [
          const BrandMark(),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'TidyDay',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: accountEnabled ? onAccount : null,
            icon: AccountAvatar(user: user, radius: 17),
          ),
        ],
      ),
    );
  }
}
