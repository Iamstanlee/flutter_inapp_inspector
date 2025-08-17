import 'package:flutter/material.dart';

class RequestMethodBadge extends StatelessWidget {
  final String method;
  final int? statusCode;

  const RequestMethodBadge({required this.method, this.statusCode, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: _getStatusColor(statusCode),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

Color _getStatusColor(int? statusCode) {
  if (statusCode == null) return Colors.grey;
  if (statusCode >= 200 && statusCode < 300) return Colors.green;
  if (statusCode >= 300 && statusCode < 400) return Colors.blue;
  if (statusCode >= 400 && statusCode < 500) return Colors.orange;
  return Colors.red;
}
