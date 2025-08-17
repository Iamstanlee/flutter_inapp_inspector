import 'dart:convert';

import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

/// A screen that displays the details of an HTTP request.
class RequestInfoScreen extends StatefulWidget {
  final HttpRequest request;

  const RequestInfoScreen({
    super.key,
    required this.request,
  });

  @override
  State<RequestInfoScreen> createState() => _RequestInfoScreenState();
}

class _RequestInfoScreenState extends State<RequestInfoScreen> {
  void _shareRequest() {
    final requestStr =
        '''<${widget.request.method}>[${widget.request.statusCode}] ${widget.request.url}\n\npayload: ${prettifyData(widget.request.data)}\n\nresponse: ${prettifyData(widget.request.response)}''';

    _copyToClipboard(requestStr);
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request ${widget.request.url}',
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: _shareRequest,
            icon: const Icon(
              Iconsax.document_copy_copy,
              size: 18,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'General',
              children: [
                _buildInfoRow('Method', widget.request.method),
                _buildInfoRow('URL', widget.request.url),
                _buildInfoRow(
                    'Status', '${widget.request.statusCode ?? "N/A"}'),
                _buildInfoRow(
                    'Time', _formatTimestamp(widget.request.timestamp)),
                _buildInfoRow(
                    'Size', _strSize(widget.request.response.toString())),
                _buildDurationRow(
                  widget.request.startTime,
                  widget.request.endTime,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Headers',
              children: [
                if (widget.request.headers != null)
                  for (final entry in widget.request.headers!.entries)
                    _buildInfoRow(entry.key, entry.value.toString()),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.request.data != null) ...[
              _buildSection(
                title: 'Payload',
                children: [
                  _buildJsonViewer(widget.request.data),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (widget.request.response != null) ...[
              _buildSection(
                title: 'Response',
                children: [
                  _buildJsonViewer(widget.request.response),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (widget.request.error != null) ...[
              _buildSection(
                title: 'Error',
                children: [
                  Text(
                    widget.request.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(value),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonViewer(dynamic data) {
    final jsonString = prettifyData(data);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        onLongPress: () => _copyToClipboard(jsonString),
        child: Text(
          jsonString.length > 10000
              ? '${jsonString.substring(0, 10000)}...'
              : jsonString,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildDurationRow(int? startTime, int? endTime) {
    if ([startTime, endTime].contains(null)) {
      return const SizedBox.shrink();
    }

    final duration = Duration(
      milliseconds: (endTime! - startTime!).abs(),
    );

    final formattedDuration = duration.inMilliseconds < 1000
        ? '${duration.inMilliseconds}ms'
        : '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';

    final requestTookTooLong = duration.inMilliseconds > 5000;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Duration',
            ),
          ),
          Expanded(
            child: Text(
              formattedDuration,
              style: TextStyle(
                fontFamily: 'monospace',
                color: requestTookTooLong ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('d/MM/yy, hh:mm a').format(timestamp);
  }

  String _strSize(String value) {
    final encoded = utf8.encode(value);
    return '${(encoded.length / 1024).toStringAsFixed(2)} kb';
  }
}
