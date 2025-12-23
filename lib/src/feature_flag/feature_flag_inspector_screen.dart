import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:flutter_inapp_inspector/src/feature_flag/feature_flag_inspector.dart';

class FeatureFlagInspectorScreen extends StatefulWidget {
  const FeatureFlagInspectorScreen({super.key});

  @override
  State<FeatureFlagInspectorScreen> createState() =>
      _FeatureFlagInspectorScreenState();
}

class _FeatureFlagInspectorScreenState
    extends State<FeatureFlagInspectorScreen> {
  FeatureFlagProvider? _provider;
  List<FeatureFlagInfo> _flags = [];
  String? _error;

  FeatureFlagProvider get provider => _provider!;

  @override
  void initState() {
    super.initState();
    try {
      final inspector = FeatureFlagInspector.instance;
      _provider = inspector.provider;
      _flags = _provider!.getFlags();
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null || _provider == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Feature flags not available.\n\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _Header(
            onClearAll: () async {
              await provider.clearAll();
              setState(() {});
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All overrides cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _flags.length,
              itemBuilder: (context, index) {
                final flag = _flags[index];
                final hasOverride = provider.hasOverride(flag.key);
                final currentValue = provider.getCurrentValue(flag.key);

                return _FlagTile(
                  flag: flag,
                  currentValue: currentValue,
                  hasOverride: hasOverride,
                  onToggle: (value) async {
                    await provider.setOverride(flag.key, value);
                    setState(() {});
                  },
                  onClearOverride: () async {
                    await provider.clearOverride(flag.key);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagTile extends StatelessWidget {
  const _FlagTile({
    required this.flag,
    required this.currentValue,
    required this.hasOverride,
    required this.onToggle,
    required this.onClearOverride,
  });

  final FeatureFlagInfo flag;
  final bool currentValue;
  final bool hasOverride;
  final ValueChanged<bool> onToggle;
  final VoidCallback onClearOverride;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(
          flag.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Default: ${flag.defaultValue}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (hasOverride) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OVERRIDE ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: currentValue,
              onChanged: onToggle,
            ),
            if (hasOverride)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClearOverride,
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClearAll});

  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Toggle flags for testing. Route changes need app restart.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton.icon(
            onPressed: onClearAll,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
