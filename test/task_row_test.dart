import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidyday/data/model/task.dart';
import 'package:tidyday/view/widget/task_row.dart';

void main() {
  testWidgets('exposes separate task completion and editing actions', (
    tester,
  ) async {
    var toggles = 0;
    var edits = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskRow(
            task: const Task(
              id: 'task-1',
              draft: TaskDraft(title: 'Submit form', notes: 'Add attachments'),
              completed: false,
            ),
            today: DateTime(2026, 3, 9),
            onToggle: () => toggles++,
            onEdit: () => edits++,
          ),
        ),
      ),
    );

    final toggle = find.bySemanticsLabel('Mark Submit form complete');
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    expect(toggles, 1);
    expect(edits, 0);

    await tester.tap(find.text('Submit form'));
    expect(toggles, 1);
    expect(edits, 1);
  }, semanticsEnabled: true);
}
