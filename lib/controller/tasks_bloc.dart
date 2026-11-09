import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasource/task_store.dart';
import '../data/model/task.dart';

sealed class TasksEvent {}

class WatchTasks extends TasksEvent {}

sealed class TaskChange extends TasksEvent {
  TaskChange(this.id);

  final String id;
}

class AddTask extends TaskChange {
  AddTask(super.id, this.draft);

  final TaskDraft draft;
}

class EditTask extends TaskChange {
  EditTask(super.id, this.draft, this.original);

  final TaskDraft draft;
  final TaskDraft original;
}

class CompleteTask extends TaskChange {
  CompleteTask(super.id, this.completed);

  final bool completed;
}

class DeleteTask extends TaskChange {
  DeleteTask(super.id);
}

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.loading = true,
    this.fromCache = false,
    this.pendingSync = false,
    this.loadFailed = false,
    this.failedChange,
    this.pendingWrites = 0,
  });

  final List<Task> tasks;
  final bool loading;
  final bool fromCache;
  final bool pendingSync;
  final bool loadFailed;
  final TaskChange? failedChange;
  final int pendingWrites;

  bool get hasPendingChanges => pendingSync || pendingWrites > 0;

  TasksState copyWith({
    List<Task>? tasks,
    bool? loading,
    bool? fromCache,
    bool? pendingSync,
    bool? loadFailed,
    TaskChange? failedChange,
    int? pendingWrites,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
      fromCache: fromCache ?? this.fromCache,
      pendingSync: pendingSync ?? this.pendingSync,
      loadFailed: loadFailed ?? this.loadFailed,
      failedChange: failedChange,
      pendingWrites: pendingWrites ?? this.pendingWrites,
    );
  }
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._store) : super(const TasksState()) {
    on<WatchTasks>(_watch);
    on<TaskChange>(_change);
  }

  final TaskStore _store;
  final _latestChanges = <String, TaskChange>{};
  bool _watching = false;

  void addTask(TaskDraft draft) => add(AddTask(_store.newId(), draft));

  void retry(TaskChange change) {
    if (identical(_latestChanges[change.id], change)) add(change);
  }

  Future<void> _watch(WatchTasks event, Emitter<TasksState> emit) async {
    if (_watching) return;
    _watching = true;
    emit(state.copyWith(loading: true, loadFailed: false));
    try {
      await emit.forEach(
        _store.watch(),
        onData: (snapshot) => state.copyWith(
          tasks: snapshot.tasks,
          loading: false,
          fromCache: snapshot.fromCache,
          pendingSync: snapshot.hasPendingWrites,
          loadFailed: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, loadFailed: true));
    } finally {
      _watching = false;
    }
  }

  Future<void> _change(TaskChange event, Emitter<TasksState> emit) async {
    _latestChanges[event.id] = event;
    emit(state.copyWith(pendingWrites: state.pendingWrites + 1));
    var failed = false;
    try {
      await switch (event) {
        AddTask(:final id, :final draft) => _store.add(id, draft),
        EditTask(:final id, :final draft, :final original) => _store.edit(
          id,
          draft,
          original,
        ),
        CompleteTask(:final id, :final completed) => _store.setCompleted(
          id,
          completed,
        ),
        DeleteTask(:final id) => _store.delete(id),
      };
    } catch (_) {
      failed = true;
    }
    if (emit.isDone) return;
    final latest = identical(_latestChanges[event.id], event);
    if (latest && !failed) _latestChanges.remove(event.id);
    emit(
      state.copyWith(
        pendingWrites: state.pendingWrites - 1,
        failedChange: latest && failed ? event : null,
      ),
    );
  }
}
