import 'package:flutter_inapp_inspector/src/storage/storage_inspector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockSecureStorage = MockFlutterSecureStorage();
    when(() => mockSharedPreferences.getKeys()).thenReturn({'key1', 'key2'});
    when(() => mockSharedPreferences.get(any())).thenReturn('value1');
  });

  tearDown(() {
    StorageInspector.instance.reset();
  });

  group('StorageInspector', () {
    test('initializePrefs should set isInitialized to true', () async {
      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);

      expect(StorageInspector.instance.isInitialized, true);
    });

    test('initializeSecureStorage should set isSecureInitialized to true',
        () async {
      await StorageInspector.instance.initializeSecureStorage(
        secureStorage: mockSecureStorage,
      );

      expect(StorageInspector.instance.isSecureInitialized, true);
    });

    test('getAllEntries should return entries from SharedPreferences',
        () async {
      when(() => mockSharedPreferences.get('key1')).thenReturn('value1');
      when(() => mockSharedPreferences.get('key2')).thenReturn('value2');

      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);

      final entries = await StorageInspector.instance.getAllEntries();

      expect(entries.length, 2);
      expect(entries[0].key, 'key1');
      expect(entries[0].value, 'value1');
      expect(entries[0].type, StorageType.sharedPreferences);
      expect(entries[1].key, 'key2');
      expect(entries[1].value, 'value2');
      expect(entries[1].type, StorageType.sharedPreferences);
    });

    test('getAllEntries should return entries from SecureStorage', () async {
      when(() => mockSecureStorage.readAll()).thenAnswer((_) async => {
            'secureKey1': 'secureValue1',
            'secureKey2': 'secureValue2',
          });

      await StorageInspector.instance
          .initializeSecureStorage(secureStorage: mockSecureStorage);

      final entries = await StorageInspector.instance.getAllEntries();

      expect(entries.length, 2);

      // Since the order of entries from a Map is not guaranteed, we need to check both possibilities
      final keys = entries.map((e) => e.key).toSet();
      expect(keys, {'secureKey1', 'secureKey2'});

      for (final entry in entries) {
        if (entry.key == 'secureKey1') {
          expect(entry.value, 'secureValue1');
          expect(entry.type, StorageType.secureStorage);
        } else if (entry.key == 'secureKey2') {
          expect(entry.value, 'secureValue2');
          expect(entry.type, StorageType.secureStorage);
        }
      }
    });

    test('getAllEntries should return entries from both storage types',
        () async {
      when(() => mockSharedPreferences.getKeys()).thenReturn({'key1'});
      when(() => mockSharedPreferences.get('key1')).thenReturn('value1');

      when(() => mockSecureStorage.readAll()).thenAnswer((_) async => {
            'secureKey1': 'secureValue1',
          });

      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);
      await StorageInspector.instance
          .initializeSecureStorage(secureStorage: mockSecureStorage);

      final entries = await StorageInspector.instance.getAllEntries();

      expect(entries.length, 2);

      // Check that we have one entry of each type
      final prefsEntries = entries
          .where((e) => e.type == StorageType.sharedPreferences)
          .toList();
      final secureEntries =
          entries.where((e) => e.type == StorageType.secureStorage).toList();

      expect(prefsEntries.length, 1);
      expect(prefsEntries[0].key, 'key1');
      expect(prefsEntries[0].value, 'value1');

      expect(secureEntries.length, 1);
      expect(secureEntries[0].key, 'secureKey1');
      expect(secureEntries[0].value, 'secureValue1');
    });

    test('deleteEntry should remove an entry from SharedPreferences', () async {
      when(() => mockSharedPreferences.remove('key1'))
          .thenAnswer((_) async => true);

      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);

      final entry = StorageEntry(
        key: 'key1',
        value: 'value1',
        type: StorageType.sharedPreferences,
      );

      await StorageInspector.instance.deleteEntry(entry);

      verify(() => mockSharedPreferences.remove('key1')).called(1);
    });

    test('deleteEntry should remove an entry from SecureStorage', () async {
      when(() => mockSecureStorage.delete(key: 'secureKey1'))
          .thenAnswer((_) async {});

      await StorageInspector.instance
          .initializeSecureStorage(secureStorage: mockSecureStorage);

      final entry = StorageEntry(
        key: 'secureKey1',
        value: 'secureValue1',
        type: StorageType.secureStorage,
      );

      await StorageInspector.instance.deleteEntry(entry);

      verify(() => mockSecureStorage.delete(key: 'secureKey1')).called(1);
    });

    test('clearEntries should clear SharedPreferences', () async {
      when(() => mockSharedPreferences.clear()).thenAnswer((_) async => true);

      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);

      await StorageInspector.instance
          .clearEntries(StorageType.sharedPreferences);

      verify(() => mockSharedPreferences.clear()).called(1);
    });

    test('clearEntries should clear SecureStorage', () async {
      when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});

      await StorageInspector.instance
          .initializeSecureStorage(secureStorage: mockSecureStorage);

      await StorageInspector.instance.clearEntries(StorageType.secureStorage);

      verify(() => mockSecureStorage.deleteAll()).called(1);
    });

    test('clearAllEntries should clear both storage types', () async {
      when(() => mockSharedPreferences.clear()).thenAnswer((_) async => true);
      when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});

      await StorageInspector.instance
          .initializePrefs(sharedPrefs: mockSharedPreferences);
      await StorageInspector.instance
          .initializeSecureStorage(secureStorage: mockSecureStorage);

      await StorageInspector.instance.clearAllEntries();

      verify(() => mockSharedPreferences.clear()).called(1);
      verify(() => mockSecureStorage.deleteAll()).called(1);
    });
  });
}
