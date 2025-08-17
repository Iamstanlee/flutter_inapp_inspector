import 'package:flutter_inapp_inspector/src/http/request_info_screen.dart';
import 'package:flutter_inapp_inspector/src/http/request_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestInfoScreen', () {
    testWidgets('should display request info', (WidgetTester tester) async {
      final request = HttpRequest(
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        method: 'GET',
        url: 'https://example.com/api',
        headers: {'Content-Type': 'application/json'},
        data: {'query': 'test'},
        statusCode: 200,
        response: {'result': 'success'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RequestInfoScreen(request: request),
        ),
      );

      expect(find.text('Request ${request.url}'), findsOneWidget);

      // General section
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('https://example.com/api'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);

      // Headers section
      expect(find.text('Headers'), findsOneWidget);
      expect(find.text('Content-Type'), findsOneWidget);
      expect(find.text('application/json'), findsOneWidget);

      // Request Data section
      expect(find.text('Payload'), findsOneWidget);
      expect(find.textContaining('"test"'), findsOneWidget);

      // Response section
      expect(find.text('Response'), findsOneWidget);
      expect(find.textContaining('"success"'), findsOneWidget);
    });

    testWidgets('should display error if present', (WidgetTester tester) async {
      final request = HttpRequest(
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        method: 'GET',
        url: 'https://example.com/api',
        statusCode: 500,
        error: 'Internal Server Error',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RequestInfoScreen(request: request),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Internal Server Error'), findsOneWidget);
    });

    testWidgets('should not display sections that are null',
        (WidgetTester tester) async {
      final request = HttpRequest(
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        method: 'GET',
        url: 'https://example.com/api',
        statusCode: 200,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RequestInfoScreen(request: request),
        ),
      );

      expect(find.text('Payload'), findsNothing);
      expect(find.text('Response'), findsNothing);
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('should handle null status code', (WidgetTester tester) async {
      final request = HttpRequest(
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        method: 'GET',
        url: 'https://example.com/api',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RequestInfoScreen(request: request),
        ),
      );

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('N/A'), findsOneWidget);
    });
  });
}
