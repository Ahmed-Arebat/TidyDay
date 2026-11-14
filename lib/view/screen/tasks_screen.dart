import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/auth_bloc.dart';
import '../../controller/tasks_bloc.dart';
import '../../data/model/task.dart';
import '../action/show_task_editor.dart';
import '../action/show_task_write_error.dart';
import '../widget/account_sheet.dart';
import '../widget/tasks_content.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.user});

  final User user;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showCompleted = false;

  void _openEditor([Task? task]) {
    showTaskEditor(
      context: context,
      bloc: context.read<TasksBloc>(),
      task: task,
    );
  }

  void _openAccount() {
    final auth = context.read<AuthBloc>();
    showAccountSheet(
      context: context,
      user: widget.user,
      onSignOut: () {
        if (!auth.isClosed) auth.add(SignOutPressed());
      },
    );
  }

  void _showWriteError(BuildContext context, TasksState state) {
    showTaskWriteError(
      context: context,
      state: state,
      bloc: context.read<TasksBloc>(),
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
            final authBusy = context.select((AuthBloc bloc) => bloc.state.busy);
            return TasksContent(
              user: widget.user,
              state: state,
              authBusy: authBusy,
              showCompleted: _showCompleted,
              onAccount: _openAccount,
              onAdd: _openEditor,
              onEdit: _openEditor,
              onToggle: (task) => context.read<TasksBloc>().add(
                CompleteTask(task.id, !task.completed),
              ),
              onRetryLoad: () => context.read<TasksBloc>().add(WatchTasks()),
              onToggleCompleted: () =>
                  setState(() => _showCompleted = !_showCompleted),
            );
          },
        ),
      ),
    );
  }
}
