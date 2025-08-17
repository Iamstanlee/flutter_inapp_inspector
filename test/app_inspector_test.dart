import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  Set<String> getKeys() => {};
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockWidgetsBinding extends Mock implements WidgetsBinding {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockSecureStorage = MockFlutterSecureStorage();

    AppInspector.dispose();
  });

  group('AppInspector', () {
    testWidgets('init should add overlay entry', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                AppInspector.init(
                  context,
                  sharedPrefs: mockSharedPreferences,
                  secureStorage: mockSecureStorage,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppInspectorView), findsOneWidget);
    });

    testWidgets('init should initialize storage inspectors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                AppInspector.init(
                  context,
                  sharedPrefs: mockSharedPreferences,
                  secureStorage: mockSecureStorage,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(StorageInspector.instance.isInitialized, true);
      expect(StorageInspector.instance.isSecureInitialized, true);
    });

    testWidgets('init should not initialize twice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // initialize once
                AppInspector.init(
                  context,
                  sharedPrefs: mockSharedPreferences,
                  secureStorage: mockSecureStorage,
                );

                // initialize again
                AppInspector.init(
                  context,
                  sharedPrefs: mockSharedPreferences,
                  secureStorage: mockSecureStorage,
                );

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppInspectorView), findsOneWidget);
    });

    testWidgets('dispose should remove the overlay entry',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                AppInspector.init(
                  context,
                  sharedPrefs: mockSharedPreferences,
                  secureStorage: mockSecureStorage,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      AppInspector.dispose();

      await tester.pumpAndSettle();

      expect(find.byType(AppInspectorView), findsNothing);
    });
  });
}
