import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDraft {
  const TaskDraft({required this.title, required this.notes, this.dueDate});

  static const titleLimit = 120;
  static const notesLimit = 1000;

  final String title;
  final String notes;
  final DateTime? dueDate;

  static String? validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Enter a task title.';
    if (title.runes.length > titleLimit) return 'Use 120 characters or fewer.';
    return null;
  }

  static String? validateNotes(String? value) {
    if ((value?.trim().runes.length ?? 0) > notesLimit) {
      return 'Use 1,000 characters or fewer.';
    }
    return null;
  }

  Map<String, Object?> toMap() => {
    'title': title,
    'notes': notes,
    'dueDate': dueDate == null ? null : encodeDay(dueDate!),
  };

  Map<String, Object?> changesFrom(TaskDraft original) {
    final previous = original.toMap();
    return toMap()..removeWhere((key, value) => previous[key] == value);
  }
}

class Task {
  const Task({
    required this.id,
    required this.draft,
    required this.completed,
    this.createdAt,
  });

  final String id;
  final TaskDraft draft;
  final bool completed;
  final DateTime? createdAt;

  factory Task.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final dueDate = data['dueDate'] as String?;
    return Task(
      id: doc.id,
      draft: TaskDraft(
        title: data['title'] as String,
        notes: data['notes'] as String,
        dueDate: decodeDay(dueDate),
      ),
      completed: data['completed'] as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

String encodeDay(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime? decodeDay(String? value) {
  if (value == null) return null;
  final date = DateTime.tryParse(value);
  return date != null && encodeDay(date) == value ? date : null;
}

int compareTasks(Task first, Task second) {
  if (first.completed != second.completed) return first.completed ? 1 : -1;
  if (!first.completed) {
    final firstDue = first.draft.dueDate;
    final secondDue = second.draft.dueDate;
    if (firstDue == null && secondDue != null) return 1;
    if (firstDue != null && secondDue == null) return -1;
    if (firstDue != null && secondDue != null) {
      final dateOrder = firstDue.compareTo(secondDue);
      if (dateOrder != 0) return dateOrder;
    }
  }

  final firstCreated = first.createdAt;
  final secondCreated = second.createdAt;
  if (firstCreated == null && secondCreated != null) return -1;
  if (firstCreated != null && secondCreated == null) return 1;
  if (firstCreated != null && secondCreated != null) {
    final creationOrder = secondCreated.compareTo(firstCreated);
    if (creationOrder != 0) return creationOrder;
  }
  return first.id.compareTo(second.id);
}
