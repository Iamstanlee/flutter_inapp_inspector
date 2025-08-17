import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:flutter/material.dart';

extension LogLevelExtension on LogLevel {
  Color get color {
    return switch (this) {
      LogLevel.debug => Colors.grey,
      LogLevel.info => Colors.black,
      LogLevel.warning => Colors.orange,
      LogLevel.error => Colors.red,
    };
  }
}
