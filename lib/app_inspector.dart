import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/log/log_inspector.dart';
import 'package:flutter_inapp_inspector/src/storage/storage_inspector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app_inspector_view.dart';

export 'src/app_inspector_view.dart';
export 'src/http/request_inspector.dart';
export 'src/log/log_inspector.dart';
export 'src/storage/storage_inspector.dart';

/// The main entry point for the App Inspector.
class AppInspector {
  static OverlayEntry? _overlayEntry;
  static bool _isInitialized = false;

  /// Initialize the App Inspector.
  ///
  /// This should only be called in debug/dev mode.
  ///
  /// Parameters:
  /// - context: The BuildContext used to add the overlay
  /// - secureStorage: Optional FlutterSecureStorage instance for the StorageInspector
  /// - sharedPrefs: Optional SharedPreferences instance for the StorageInspector
  /// - navigatorObservers: Optional list of NavigatorObservers to add the NavigationInspector to
  static void init(
    BuildContext context, {
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPrefs,
  }) {
    if (_isInitialized) return;
    _isInitialized = true;

    // Initialize StorageInspector
    if (sharedPrefs != null) {
      StorageInspector.instance.initializePrefs(sharedPrefs: sharedPrefs);
    }

    if (secureStorage != null) {
      StorageInspector.instance
          .initializeSecureStorage(secureStorage: secureStorage);
    }

    // Add a log message to indicate that the App Inspector is initialized
    const LogFactory('AppInspector').i('App Inspector initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) => _addOverlay(context));
  }

  static void _addOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => const AppInspectorView(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isInitialized = false;
  }
}
