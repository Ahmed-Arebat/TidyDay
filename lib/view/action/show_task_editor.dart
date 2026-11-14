import 'package:flutter/material.dart';

import '../../controller/tasks_bloc.dart';
import '../../data/model/task.dart';
import '../widget/task_editor.dart';

Future<void> showTaskEditor({
  required BuildContext context,
  required TasksBloc bloc,
  Task? task,
}) {
  return showModalBottomSheet<void>(
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
