import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sla_task_tracker/main.dart';

void main() {
  testWidgets('app starts on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SlaTaskTrackerApp());

    expect(find.text('SLA Task Tracker'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
