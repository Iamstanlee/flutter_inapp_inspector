import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import 'storage_inspector.dart';

/// A screen that displays storage entries.
class StorageInspectorScreen extends StatefulWidget {
  const StorageInspectorScreen({super.key});

  @override
  State<StorageInspectorScreen> createState() => _StorageInspectorScreenState();
}

class _StorageInspectorScreenState extends State<StorageInspectorScreen> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      getEntries();
    }
  }

  Future<void> getEntries() async {
    await StorageInspector.instance.refreshEntries();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<StorageEntry>>(
        future: Future.value(StorageInspector.instance.entries),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No storage entries found'),
            );
          }

          // Group entries by type
          final sharedPrefsEntries = entries
              .where((e) => e.type == StorageType.sharedPreferences)
              .toList();
          final secureStorageEntries = entries
              .where((e) => e.type == StorageType.secureStorage)
              .toList();

          return ListView(
            children: [
              if (sharedPrefsEntries.isNotEmpty) ...[
                _buildStorageSection(
                  'Shared Preferences',
                  sharedPrefsEntries,
                  StorageType.sharedPreferences,
                ),
              ],
              const SizedBox(height: 16),
              if (secureStorageEntries.isNotEmpty) ...[
                _buildStorageSection(
                  'Secure Storage',
                  secureStorageEntries,
                  StorageType.secureStorage,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStorageSection(
    String title,
    List<StorageEntry> entries,
    StorageType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 4,
            children: [
              type == StorageType.secureStorage
                  ? const Icon(
                      Iconsax.lock_circle,
                      size: 18,
                    )
                  : const Icon(
                      Iconsax.box_1,
                      size: 18,
                    ),
              Text(title, style: TextStyle(fontSize: 12))
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildStorageEntryItem(entry);
          },
        ),
      ],
    );
  }

  Widget _buildStorageEntryItem(StorageEntry entry) {
    final isCache = entry.key.contains('httpcache');
    String value = '${entry.value}';

    if (isCache) {
      value =
          'Expire At: ${_formatTimestamp(jsonDecode(entry.value)['expiration'])}';
    }

    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          barrierColor: Colors.black.withAlpha(200),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          builder: (context) => _InfoBottomsheet(
            entry: entry,
            isCache: isCache,
          ),
        );
      },
      title: Text(entry.key, style: TextStyle(fontSize: 12)),
      subtitle: isCache
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value,
                maxLines: 2,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCache)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Text(
                'CACHE',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(
              Iconsax.document_copy1,
              size: 18,
              color: Colors.black,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${entry.value}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Value copied to clipboard'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Iconsax.trash,
              color: Colors.red,
              size: 18,
            ),
            onPressed: () async {
              await StorageInspector.instance.deleteEntry(entry);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('d/MM/yy, hh:mm:ss a').format(dateTime);
  }
}

class _InfoBottomsheet extends StatelessWidget {
  final StorageEntry entry;
  final bool isCache;

  const _InfoBottomsheet({
    required this.entry,
    required this.isCache,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                entry.key,
                style: TextStyle(),
              ),
              Text(
                'Value:',
                style: TextStyle(),
              ),
              _jsonPrettyPrint(entry.value, isCache),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jsonPrettyPrint(dynamic json, bool isCache) {
    try {
      final decoded = jsonDecode(json);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(
        isCache ? jsonDecode(decoded['data']) : decoded,
      );
      return SelectableText(
        prettyJson,
        style: TextStyle(),
      );
    } catch (e) {
      return SelectableText(
        '$json',
        style: TextStyle(),
      );
    }
  }
}
