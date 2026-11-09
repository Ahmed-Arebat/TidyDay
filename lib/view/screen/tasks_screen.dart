import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/auth_bloc.dart';
import '../../controller/tasks_bloc.dart';
import '../../core/constant/app_theme.dart';
import '../../data/model/task.dart';
import '../widget/brand_mark.dart';
import '../widget/task_editor.dart';
import '../widget/task_row.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.user});

  final User user;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showCompleted = false;

  void _openEditor([Task? task]) {
    final bloc = context.read<TasksBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => TaskEditor(
        task: task,
        onSave: (draft) {
          if (ModalRoute.of(sheetContext)?.isCurrent != true) return;
          Navigator.pop(sheetContext);
          if (bloc.isClosed) return;
          if (task == null) {
            bloc.addTask(draft);
          } else {
            bloc.add(EditTask(task.id, draft, task.draft));
          }
        },
        onDelete: task == null
            ? null
            : () {
                if (ModalRoute.of(sheetContext)?.isCurrent != true) return;
                Navigator.pop(sheetContext);
                if (!bloc.isClosed) bloc.add(DeleteTask(task.id));
              },
      ),
    );
  }

  void _openAccount() {
    final auth = context.read<AuthBloc>();
    final user = widget.user;
    final name = user.displayName?.trim();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) {
        final text = Theme.of(sheetContext).textTheme;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your account', style: text.headlineSmall),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _AccountAvatar(user: user),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name == null || name.isEmpty
                                ? 'Google account'
                                : name,
                            style: text.titleMedium,
                          ),
                          if (user.email case final String email)
                            Text(
                              email,
                              style: text.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    if (!auth.isClosed) auth.add(SignOutPressed());
                  },
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWriteError(BuildContext context, TasksState state) {
    final change = state.failedChange;
    if (change == null) return;
    final bloc = context.read<TasksBloc>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not save your change.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            if (!bloc.isClosed) bloc.retry(change);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.user != null,
      listener: (context, state) {
        if (state.error case final String message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        body: BlocConsumer<TasksBloc, TasksState>(
          listenWhen: (_, current) => current.failedChange != null,
          listener: _showWriteError,
          builder: (context, state) {
            final today = DateUtils.dateOnly(DateTime.now());
            final open = state.tasks.where((task) => !task.completed).toList();
            final completed = state.tasks
                .where((task) => task.completed)
                .toList();
            final authBusy = context.select((AuthBloc bloc) => bloc.state.busy);
            final ready = !state.loading && !state.loadFailed;
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 14, 5),
                        child: Row(
                          children: [
                            const BrandMark(),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'TidyDay',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Account',
                              onPressed: authBusy ? null : _openAccount,
                              icon: _AccountAvatar(
                                user: widget.user,
                                radius: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      Expanded(
                        child: Stack(
                          children: [
                            CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    23,
                                    20,
                                    20,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _Overview(
                                      today: today,
                                      total: state.tasks.length,
                                      completed: completed.length,
                                      showProgress:
                                          ready || state.tasks.isNotEmpty,
                                    ),
                                  ),
                                ),
                                if (state.loading && state.tasks.isEmpty)
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          semanticsLabel: 'Loading tasks',
                                        ),
                                      ),
                                    ),
                                  ),
                                if (state.loadFailed)
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      16,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _ListMessage(
                                        icon: Icons.cloud_off_outlined,
                                        title: 'Could not load tasks',
                                        detail:
                                            'Check your connection and try again.',
                                        action: TextButton(
                                          onPressed: () => context
                                              .read<TasksBloc>()
                                              .add(WatchTasks()),
                                          child: const Text('Retry'),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (ready &&
                                    (state.hasPendingChanges ||
                                        state.fromCache))
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      16,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _SyncNotice(
                                        pending: state.hasPendingChanges,
                                      ),
                                    ),
                                  ),
                                if (ready && state.tasks.isEmpty)
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: state.fromCache
                                          ? const _ListMessage(
                                              icon: Icons.cloud_outlined,
                                              title: 'Waiting for your tasks',
                                              detail:
                                                  'Your list will refresh when you connect.',
                                            )
                                          : const _ListMessage(
                                              icon: Icons.checklist_rounded,
                                              title: 'A fresh start',
                                              detail:
                                                  'Add a task to start planning your day.',
                                            ),
                                    ),
                                  ),
                                if (open.isNotEmpty) ...[
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      10,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _SectionLabel(
                                        title: 'Open',
                                        count: open.length,
                                      ),
                                    ),
                                  ),
                                  _taskList(open, today),
                                ],
                                if (completed.isNotEmpty) ...[
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _CompletedHeading(
                                        count: completed.length,
                                        expanded: _showCompleted,
                                        onPressed: () => setState(
                                          () =>
                                              _showCompleted = !_showCompleted,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_showCompleted)
                                    _taskList(completed, today),
                                ],
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 88),
                                ),
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
                                    onPressed: _openEditor,
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
          },
        ),
      ),
    );
  }

  Widget _taskList(List<Task> tasks, DateTime today) {
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
              onEdit: () => _openEditor(task),
              onToggle: () => context.read<TasksBloc>().add(
                CompleteTask(task.id, !task.completed),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.user, this.radius = 22});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final name = (user.displayName ?? user.email ?? '').trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.soft,
      foregroundColor: AppColors.primary,
      child: name.isEmpty
          ? Icon(Icons.person_outline_rounded, size: radius)
          : Text(
              String.fromCharCode(name.runes.first).toUpperCase(),
              style: TextStyle(
                fontSize: radius * .8,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.count});

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

class _CompletedHeading extends StatelessWidget {
  const _CompletedHeading({
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
                child: _SectionLabel(title: 'Completed', count: count),
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

class _ListMessage extends StatelessWidget {
  const _ListMessage({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          if (action case final Widget button) button,
        ],
      ),
    );
  }
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.pending});

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
