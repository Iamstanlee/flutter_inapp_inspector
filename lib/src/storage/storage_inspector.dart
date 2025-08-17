import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A model class representing a storage entry.
class StorageEntry {
  final String key;
  final dynamic value;
  final StorageType type;

  StorageEntry({
    required this.key,
    required this.value,
    required this.type,
  });
}

/// The type of storage.
enum StorageType {
  sharedPreferences,
  secureStorage,
}

/// The StorageInspector class is responsible for accessing and managing storage.
class StorageInspector {
  static final StorageInspector instance = StorageInspector._internal();

  StorageInspector._internal();

  bool isInitialized = false;
  bool isSecureInitialized = false;

  late FlutterSecureStorage _secureStorage;
  late SharedPreferences _sharedPreferences;

  List<StorageEntry> _entries = [];

  List<StorageEntry> get entries => List.unmodifiable(_entries);

  Future<void> initializePrefs({
    required SharedPreferences sharedPrefs,
  }) async {
    isInitialized = true;

    _sharedPreferences = sharedPrefs;
    refreshEntries();
  }

  Future<void> initializeSecureStorage({
    required FlutterSecureStorage secureStorage,
  }) async {
    isSecureInitialized = true;

    _secureStorage = secureStorage;
    refreshEntries();
  }

  /// Get all storage entries.
  Future<List<StorageEntry>> getAllEntries() async {
    final entries = <StorageEntry>[];
    if (isInitialized) {
      final keys = _sharedPreferences.getKeys();
      for (final key in keys) {
        final value = _sharedPreferences.get(key);
        entries.add(StorageEntry(
          key: key,
          value: value,
          type: StorageType.sharedPreferences,
        ));
      }
    }

    if (isSecureInitialized) {
      try {
        final secureEntries = await _secureStorage.readAll();
        for (final entry in secureEntries.entries) {
          entries.add(StorageEntry(
            key: entry.key,
            value: entry.value,
            type: StorageType.secureStorage,
          ));
        }
      } catch (e) {
        //   no-op
      }
    }

    return entries;
  }

  /// Delete a storage entry.
  Future<void> deleteEntry(StorageEntry entry) async {
    if (entry.type == StorageType.sharedPreferences) {
      await _sharedPreferences.remove(entry.key);
    } else if (entry.type == StorageType.secureStorage) {
      await _secureStorage.delete(key: entry.key);
    }

    await refreshEntries();
  }

  /// Clear all entries of a specific type.
  Future<void> clearEntries(StorageType type) async {
    if (type == StorageType.sharedPreferences) {
      await _sharedPreferences.clear();
    } else if (type == StorageType.secureStorage) {
      await _secureStorage.deleteAll();
    }

    await refreshEntries();
  }

  /// Clear all entries.
  Future<void> clearAllEntries() async {
    await _sharedPreferences.clear();
    await _secureStorage.deleteAll();

    await refreshEntries();
  }

  /// Refresh the list of entries and notify listeners.
  Future<void> refreshEntries() async {
    _entries = await getAllEntries();
  }

  @visibleForTesting
  void reset() {
    isInitialized = false;
    isSecureInitialized = false;
  }
}
