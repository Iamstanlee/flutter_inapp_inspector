import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/http/components/request_method_badge.dart';

import 'request_info_screen.dart';
import 'request_inspector.dart';

/// A screen that displays a list of HTTP requests.
class RequestInspectorScreen extends StatefulWidget {
  const RequestInspectorScreen({super.key});

  @override
  State<RequestInspectorScreen> createState() => _RequestInspectorScreenState();
}

class _RequestInspectorScreenState extends State<RequestInspectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<HttpRequest>>(
        stream: RequestInspector.instance.requestsStream,
        initialData: RequestInspector.instance.requests,
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text('No requests captured yet'),
            );
          }

          return ListView.separated(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestItem(
                context,
                request,
                requests.length - index,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context,
    HttpRequest request,
    int index,
  ) {
    final statusColor = _getStatusColor(request.statusCode);

    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          RequestMethodBadge(
            method: request.method,
            statusCode: request.statusCode,
          ),
          Expanded(
            child: Text(
              request.url,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: ${request.statusCode ?? "Connection Failed"}',
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
            ),
          ),
          Text(
            'Duration: ${_formatDuration(request.startTime, request.endTime)}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: _getDurationColor(request.startTime, request.endTime),
            ),
          ),
        ],
      ),
      trailing: Text(
        '#$index',
        style: TextStyle(fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestInfoScreen(request: request),
          ),
        );
      },
    );
  }

  Color _getStatusColor(int? statusCode) {
    if (statusCode == null) return Colors.grey;
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.blue;
    if (statusCode >= 400 && statusCode < 500) return Colors.orange;
    return Colors.red;
  }

  Color _getDurationColor(int? startTime, int? endTime) {
    if ([startTime, endTime].contains(null)) {
      return Colors.grey;
    }

    final duration = Duration(
      milliseconds: (endTime! - startTime!).abs(),
    );

    return duration.inMilliseconds > 5000 ? Colors.red : Colors.grey;
  }

  String _formatDuration(int? startTime, int? endTime) {
    if ([startTime, endTime].contains(null)) {
      return '-';
    }

    final duration = Duration(
      milliseconds: (endTime! - startTime!).abs(),
    );

    final formattedDuration = duration.inMilliseconds < 1000
        ? '${duration.inMilliseconds}ms'
        : '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';

    return formattedDuration;
  }
}
