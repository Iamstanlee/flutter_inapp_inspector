import 'package:flutter/widgets.dart';

/// Contract for providing feature flag values and overrides
///
/// Implementations are responsible for:
/// - Defining the available feature flags
/// - Resolving the effective value of a flag
/// - Persisting overrides if applicable
abstract class FeatureFlagProvider {
  /// Returns all feature flags supported by the host application
  List<FeatureFlagInfo> getFlags();

  /// Returns the effective value of a feature flag
  bool getCurrentValue(String key);

  /// Returns `true` if the given flag currently has an override applied
  bool hasOverride(String key);

  /// Applies an override value for a feature flag
  Future<void> setOverride(String key, bool value);

  /// Clears the override for a specific feature flag
  Future<void> clearOverride(String key);

  /// Clears all feature flag overrides.
  Future<void> clearAll();
}

/// Immutable metadata describing a single feature flag
///
/// This does not represent the current value of the flag,
/// only its identity and default behavior
@immutable
class FeatureFlagInfo {
  /// Unique identifier for the feature flag
  final String key;

  /// Human-readable name used in UIs or debugging tools
  final String displayName;

  /// Default value when no override is applied.
  final bool defaultValue;

  const FeatureFlagInfo({
    required this.key,
    required this.displayName,
    required this.defaultValue,
  });
}
