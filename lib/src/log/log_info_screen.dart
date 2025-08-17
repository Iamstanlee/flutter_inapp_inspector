import 'package:flutter_inapp_inspector/src/log/log_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'log_inspector.dart';

/// A screen that displays detailed information about a log entry.
class LogInfoScreen extends StatelessWidget {
  final LogEntry log;

  const LogInfoScreen({
    required this.log,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log',
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Level'),
            _buildLevelCard(log.level),
            const SizedBox(height: 16),
            if (log.tag != null) ...[
              _buildSectionTitle('Tag'),
              _buildInfoCard(log.tag!),
              const SizedBox(height: 16),
            ],
            _buildSectionTitle('Timestamp'),
            _buildInfoCard(_formatTimestamp(log.timestamp)),
            const SizedBox(height: 16),
            _buildSectionTitle('Message'),
            _buildMessageCard(log.message),
            const SizedBox(height: 16),
            if (log.stackTrace != null) ...[
              _buildSectionTitle('Stack Trace'),
              _buildStackTraceCard(log.stackTrace.toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 12)
      ),
    );
  }

  Widget _buildLevelCard(LogLevel level) {
    final color = level.color;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              level.name,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String content) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            content,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            prettifyData(message),
            style: TextStyle(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackTraceCard(String stackTrace) {
    return Card(
      elevation: 1,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            stackTrace,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('d/MM/yyyy, hh:mm:ss a').format(timestamp);
  }
}
