import 'package:flutter_inapp_inspector/src/feature_flag/feature_flag_provider.dart';

class FeatureFlagInspector {
  static final FeatureFlagInspector instance = FeatureFlagInspector._();

  FeatureFlagInspector._();

  FeatureFlagProvider? _provider;

  /// Initialize with a provider implementation from the host app
  void initialize(FeatureFlagProvider provider) {
    _provider = provider;
  }

  /// Returns the active [FeatureFlagProvider]
  ///
  /// Throws a [StateError] if the inspector has not been initialized.
  FeatureFlagProvider get provider {
    if (_provider == null) {
      throw StateError('FeatureFlagInspector not initialized');
    }
    return _provider!;
  }
}
