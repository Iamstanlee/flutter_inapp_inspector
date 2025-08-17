import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inapp_inspector/src/dashboard/dashboard_screen.dart';
import 'package:flutter_inapp_inspector/src/http/request_inspector_screen.dart';
import 'package:flutter_inapp_inspector/src/storage/storage_inspector_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('DashboardOverviewScreen', () {
    late MockVoidCallback mockOnClose;

    setUp(() {
      mockOnClose = MockVoidCallback();
    });

    testWidgets('should render with app bar and tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardOverviewScreen(
            onClose: mockOnClose.call,
          ),
        ),
      );

      expect(find.text('App Inspector'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);

      // Initially, the Requests tab should be visible
      expect(find.byType(RequestInspectorScreen), findsOneWidget);
      expect(find.byType(StorageInspectorScreen), findsNothing);
    });

    testWidgets('should switch to Storage tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardOverviewScreen(
            onClose: mockOnClose.call,
          ),
        ),
      );

      // Initially, the Requests tab should be visible
      expect(find.byType(RequestInspectorScreen), findsOneWidget);
      expect(find.byType(StorageInspectorScreen), findsNothing);

      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();

      // Storage tab should be visible
      expect(find.byType(RequestInspectorScreen), findsNothing);
      expect(find.byType(StorageInspectorScreen), findsOneWidget);
    });

    testWidgets('should switch back to Requests tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardOverviewScreen(
            onClose: mockOnClose.call,
          ),
        ),
      );

      // Switch to Storage tab
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();

      // Verify Storage tab is visible
      expect(find.byType(RequestInspectorScreen), findsNothing);
      expect(find.byType(StorageInspectorScreen), findsOneWidget);

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      // Requests tab should be visible again
      expect(find.byType(RequestInspectorScreen), findsOneWidget);
      expect(find.byType(StorageInspectorScreen), findsNothing);
    });
  });
}
