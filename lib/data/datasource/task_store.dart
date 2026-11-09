import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task.dart';

class TaskSnapshot {
  const TaskSnapshot(this.tasks, this.fromCache, this.hasPendingWrites);

  final List<Task> tasks;
  final bool fromCache;
  final bool hasPendingWrites;
}

class TaskStore {
  TaskStore(FirebaseFirestore firestore, String uid)
    : _tasks = firestore.collection('users').doc(uid).collection('tasks');

  final CollectionReference<Map<String, dynamic>> _tasks;

  Stream<TaskSnapshot> watch() {
    return _tasks.snapshots(includeMetadataChanges: true).map((snapshot) {
      final tasks = snapshot.docs.map(Task.fromDocument).toList()
        ..sort(compareTasks);
      return TaskSnapshot(
        tasks,
        snapshot.metadata.isFromCache,
        snapshot.metadata.hasPendingWrites,
      );
    });
  }

  String newId() => _tasks.doc().id;

  Future<void> add(String id, TaskDraft draft) {
    return _tasks.doc(id).set({
      ...draft.toMap(),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> edit(String id, TaskDraft draft, TaskDraft original) async {
    final changes = draft.changesFrom(original);
    if (changes.isNotEmpty) await _tasks.doc(id).update(changes);
  }

  Future<void> setCompleted(String id, bool completed) {
    return _tasks.doc(id).update({'completed': completed});
  }

  Future<void> delete(String id) => _tasks.doc(id).delete();
}
