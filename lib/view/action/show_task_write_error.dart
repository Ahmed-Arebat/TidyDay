import 'package:flutter/material.dart';

import '../../controller/tasks_bloc.dart';

void showTaskWriteError({
  required BuildContext context,
  required TasksState state,
  required TasksBloc bloc,
}) {
  final change = state.failedChange;
  if (change == null) return;
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
