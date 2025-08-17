import 'package:flutter_inapp_inspector/src/http/request_info_screen.dart';
import 'package:flutter_inapp_inspector/src/http/request_inspector.dart';
import 'package:flutter_inapp_inspector/src/http/request_inspector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpRequest extends Mock implements HttpRequest {}

void main() {
  group('RequestInspectorScreen', () {
    setUp(() {
      RequestInspector.instance.clearRequests();
    });

    testWidgets('should show empty state when no requests',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestInspectorScreen(),
          ),
        ),
      );

      expect(find.text('No requests captured yet'), findsOneWidget);
    });

    testWidgets('should show list of requests', (WidgetTester tester) async {
      final request1 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api/1',
        statusCode: 200,
      );

      final request2 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'POST',
        url: 'https://example.com/api/2',
        statusCode: 400,
      );

      RequestInspector.instance.addRequest(request1);
      RequestInspector.instance.addRequest(request2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestInspectorScreen(),
          ),
        ),
      );

      expect(find.text('https://example.com/api/1'), findsOneWidget);
      expect(find.text('https://example.com/api/2'), findsOneWidget);
    });

    testWidgets('should navigate to info screen when request is tapped',
        (WidgetTester tester) async {
      final request = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api',
        statusCode: 200,
      );

      RequestInspector.instance.addRequest(request);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestInspectorScreen(),
          ),
        ),
      );

      await tester.tap(find.text('https://example.com/api'));
      await tester.pumpAndSettle();

      expect(find.byType(RequestInfoScreen), findsOneWidget);
      expect(find.text('Request ${request.url}'), findsOneWidget);
    });

    testWidgets('should show status color based on status code',
        (WidgetTester tester) async {
      final request1 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api/success',
        statusCode: 200,
      );

      final request2 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api/redirect',
        statusCode: 301,
      );

      final request3 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api/error',
        statusCode: 404,
      );

      final request4 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/api/server-error',
        statusCode: 500,
      );

      RequestInspector.instance.addRequest(request1);
      RequestInspector.instance.addRequest(request2);
      RequestInspector.instance.addRequest(request3);
      RequestInspector.instance.addRequest(request4);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestInspectorScreen(),
          ),
        ),
      );

      expect(find.text('Status: 200'), findsOneWidget);
      expect(find.text('Status: 301'), findsOneWidget);
      expect(find.text('Status: 404'), findsOneWidget);
      expect(find.text('Status: 500'), findsOneWidget);
    });
  });
}
