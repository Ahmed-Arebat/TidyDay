import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tidyday/view/widget/task_loading_skeleton.dart';

void main() {
  testWidgets(
    'shows a task-shaped skeleton with an accessible loading label',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TaskLoadingSkeleton()),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel('Loading tasks'), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is Bone), findsWidgets);
    },
    semanticsEnabled: true,
  );
}
