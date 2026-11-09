import 'package:flutter_test/flutter_test.dart';
import 'package:tidyday/data/model/task.dart';

void main() {
  test('validates required titles and optional notes after trimming', () {
    expect(TaskDraft.validateTitle(null), isNotNull);
    expect(TaskDraft.validateTitle('   '), isNotNull);
    expect(TaskDraft.validateTitle(' ${'أ' * 120} '), isNull);
    expect(TaskDraft.validateTitle('a' * 121), isNotNull);
    expect(TaskDraft.validateNotes(null), isNull);
    expect(TaskDraft.validateNotes('n' * 1000), isNull);
    expect(TaskDraft.validateNotes('n' * 1001), isNotNull);
  });

  test('writes a date as a calendar day and preserves an empty date', () {
    final dueDate = DateTime(2026, 3, 9, 23, 45);
    final scheduled = TaskDraft(
      title: 'Submit form',
      notes: '',
      dueDate: dueDate,
    );
    const unscheduled = TaskDraft(title: 'Tidy desk', notes: 'Recycle papers');

    expect(scheduled.toMap()['dueDate'], '2026-03-09');
    expect(decodeDay(encodeDay(dueDate)), DateTime(2026, 3, 9));
    expect(decodeDay('2026-02-30'), isNull);
    expect(unscheduled.toMap(), {
      'title': 'Tidy desk',
      'notes': 'Recycle papers',
      'dueDate': null,
    });
  });

  test('edits patch only changed fields and can clear a date', () {
    final original = TaskDraft(
      title: 'Submit form',
      notes: 'Keep these notes',
      dueDate: DateTime(2026, 3, 9),
    );
    final renamed = TaskDraft(
      title: 'Submit application',
      notes: original.notes,
      dueDate: original.dueDate,
    );
    final undated = TaskDraft(title: original.title, notes: original.notes);

    expect(renamed.changesFrom(original), {'title': 'Submit application'});
    expect(undated.changesFrom(original), {'dueDate': null});
    expect(original.changesFrom(original), isEmpty);
  });

  test(
    'orders open tasks by due day, with undated and completed tasks last',
    () {
      final tasks = [
        const Task(
          id: 'undated',
          draft: TaskDraft(title: 'Tidy desk', notes: ''),
          completed: false,
        ),
        Task(
          id: 'completed',
          draft: TaskDraft(
            title: 'Read email',
            notes: '',
            dueDate: DateTime(2026, 3, 1),
          ),
          completed: true,
        ),
        Task(
          id: 'later',
          draft: TaskDraft(
            title: 'Order supplies',
            notes: '',
            dueDate: DateTime(2026, 3, 21),
          ),
          completed: false,
        ),
        Task(
          id: 'earlier',
          draft: TaskDraft(
            title: 'Send form',
            notes: '',
            dueDate: DateTime(2026, 3, 2),
          ),
          completed: false,
        ),
      ]..sort(compareTasks);

      expect(tasks.map((task) => task.id), [
        'earlier',
        'later',
        'undated',
        'completed',
      ]);
    },
  );

  test('orders tasks with the same due day by newest first', () {
    final draft = TaskDraft(
      title: 'Buy groceries',
      notes: '',
      dueDate: DateTime(2026, 3, 9),
    );
    final tasks = [
      Task(
        id: 'older',
        draft: draft,
        completed: false,
        createdAt: DateTime(2026, 3, 1),
      ),
      Task(
        id: 'newer',
        draft: draft,
        completed: false,
        createdAt: DateTime(2026, 3, 3),
      ),
    ]..sort(compareTasks);

    expect(tasks.map((task) => task.id), ['newer', 'older']);
  });
}
