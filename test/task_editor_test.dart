import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidyday/data/model/task.dart';
import 'package:tidyday/view/widget/task_editor.dart';

void main() {
  testWidgets('validates and saves a task on a narrow screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    TaskDraft? saved;
    await openEditor(tester, onSave: (draft) => saved = draft, textScale: 1.5);

    final title = find.byType(TextFormField).first;
    final notes = find.byType(TextFormField).last;
    final save = find.text('Add task');

    await tester.enterText(title, '   ');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Enter a task title.'), findsOneWidget);
    expect(saved, isNull);

    await tester.ensureVisible(title);
    await tester.enterText(title, '  Submit form  ');
    await tester.ensureVisible(notes);
    await tester.enterText(notes, '  Add attachments  ');
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(saved?.title, 'Submit form');
    expect(saved?.notes, 'Add attachments');
    expect(saved?.dueDate, isNull);
  });

  testWidgets('removes an existing due date while keeping the title', (
    tester,
  ) async {
    final task = Task(
      id: 'task-1',
      draft: TaskDraft(
        title: 'Call the dentist',
        notes: '',
        dueDate: DateTime(2026, 3, 9),
      ),
      completed: false,
    );
    TaskDraft? saved;
    await openEditor(tester, task: task, onSave: (draft) => saved = draft);

    await tester.tap(find.byTooltip('Remove due date'));
    await tester.pumpAndSettle();
    expect(find.text('Add due date'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(saved?.title, 'Call the dentist');
    expect(saved?.dueDate, isNull);
  });
}

Future<void> openEditor(
  WidgetTester tester, {
  required ValueChanged<TaskDraft> onSave,
  Task? task,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (sheetContext) => TaskEditor(
                task: task,
                onSave: (draft) {
                  onSave(draft);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}
