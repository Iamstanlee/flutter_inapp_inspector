import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/log/log_extension.dart';
import 'package:intl/intl.dart';

import 'log_info_screen.dart';
import 'log_inspector.dart';

/// A screen that displays a list of logs with their levels and messages.
class LogInspectorScreen extends StatefulWidget {
  const LogInspectorScreen({super.key});

  @override
  State<LogInspectorScreen> createState() => _LogInspectorScreenState();
}

class _LogInspectorScreenState extends State<LogInspectorScreen> {
  final Set<LogLevel> _selectedLevels = Set.from(LogLevel.values);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<LogEntry>>(
        stream: LogInspector.instance.logsStream,
        initialData: LogInspector.instance.logs,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          final filteredLogs = logs
              .where(
                (log) => _selectedLevels.contains(log.level),
              )
              .toList();

          if (filteredLogs.isEmpty) {
            return const Center(
              child: Text('No logs captured yet'),
            );
          }

          return ListView.separated(
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              return _buildLogItem(
                context,
                log,
                filteredLogs.length - index,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, LogEntry log, int index) {
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: log.level.color,
            ),
            child: Text(
              log.level.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          if (log.tag != null) ...[
            Expanded(
              child: Text(
                log.tag!,
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prettifyData(log.message),
            style: TextStyle(fontSize: 12),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Time: ${_formatTimestamp(log.timestamp)}',
            style: TextStyle(fontSize: 12),
          ),
          if (log.hasError)
            Text(
              'Error: ${log.error}',
              style: TextStyle(fontSize: 12, color: Colors.red),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Text('#$index', style: TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogInfoScreen(log: log),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('d/MM/yy, hh:mm:ss a').format(timestamp);
  }
}
