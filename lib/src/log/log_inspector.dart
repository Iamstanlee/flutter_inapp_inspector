import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Enum representing different log levels
enum LogLevel {
  debug,
  info,
  warning,
  error;

  String get name {
    return switch (this) {
      LogLevel.debug => 'DEBUG',
      LogLevel.info => 'INFO',
      LogLevel.warning => 'WARNING',
      LogLevel.error => 'ERROR',
    };
  }

  int toDartLogLevel() {
    switch (this) {
      case LogLevel.error:
        return 1000;
      case LogLevel.warning:
        return 900;
      case LogLevel.info:
        return 800;
      case LogLevel.debug:
        return 700;
    }
  }

  bool get isFatal {
    return [
      LogLevel.error,
      LogLevel.warning,
    ].contains(this);
  }
}

/// Represents a log entry
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  bool get hasError => error != null;
}

/// The LogInspector class is responsible for capturing and storing logs.
class LogInspector {
  static final LogInspector instance = LogInspector._internal();

  LogInspector._internal();

  final List<LogEntry> _logs = [];
  final StreamController<List<LogEntry>> _logsStreamController =
      StreamController<List<LogEntry>>.broadcast();

  Stream<List<LogEntry>> get logsStream => _logsStreamController.stream;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Logs a message at the specified level
  void log(
    Object message, {
    LogLevel level = LogLevel.info,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      message: message.toString(),
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
    StringBuffer log = StringBuffer();
    log.write("[${entry.level.name}]($tag) ${entry.message}");
    if (entry.stackTrace != null) {
      log.write("\n${entry.stackTrace}");
    }

    if (kDebugMode) {
      debugPrint(log.toString());
    }

    _addLogEntry(entry);

    _callback?.call(entry);
  }

  void _addLogEntry(LogEntry entry) {
    _logs.insert(0, entry); // Most recent first
    _logsStreamController.add(_logs);
  }

  void clearLogs() {
    _logs.clear();
    _logsStreamController.add(_logs);
  }

  ValueSetter<LogEntry>? _callback;

  void setLogCallback(ValueSetter<LogEntry> callback) {
    _callback = callback;
  }
}

class LogFactory {
  final String _tag;

  const LogFactory(this._tag);

  /// Logs a debug message
  void d(Object message, [StackTrace? stackStrace]) {
    LogInspector.instance.log(
      message,
      tag: _tag,
      level: LogLevel.debug,
      stackTrace: stackStrace,
    );
  }

  /// Logs an info message
  void i(Object message, [StackTrace? stackStrace]) {
    LogInspector.instance.log(
      message,
      tag: _tag,
      level: LogLevel.info,
      stackTrace: stackStrace,
    );
  }

  /// Logs an warning message
  void w(Object message, [StackTrace? stackStrace]) {
    LogInspector.instance.log(
      message,
      tag: _tag,
      level: LogLevel.warning,
      stackTrace: stackStrace,
    );
  }

  /// Logs an error message
  void e(Object message, [StackTrace? stackStrace]) {
    LogInspector.instance.log(
      message,
      tag: _tag,
      level: LogLevel.error,
      stackTrace: stackStrace,
    );
  }
}

String prettifyData(dynamic data) {
  try {
    return JsonEncoder.withIndent('  ').convert(
      data is String ? jsonDecode(data) : data,
    );
  } catch (e) {
    // If the data is not JSON serializable, return a string representation
    return data.toString();
  }
}
