import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/app_inspector_view.dart';
import 'package:flutter_inapp_inspector/src/dashboard/dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInspectorView', () {
    testWidgets('should render a floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInspectorView(),
          ),
        ),
      );

      expect(find.byKey(fabKey), findsOneWidget);
    });

    testWidgets('should show dashboard when FAB is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInspectorView(),
          ),
        ),
      );

      await tester.tap(find.byKey(fabKey));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardOverviewScreen), findsOneWidget);
    });
  });
}
