import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void _output(String line, {Object? error, StackTrace? stackTrace}) {
    developer.log(line, error: error, stackTrace: stackTrace);
    if (kReleaseMode) {
      // ignore: avoid_print
      print(line);
      if (error != null) print('  error: $error');
      if (stackTrace != null) print('  $stackTrace');
    }
  }

  static void info(String tag, String message) {
    final timestamp = DateTime.now().toIso8601String();
    _output('[$timestamp] INFO [$tag] $message');
  }

  static void error(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    _output('[$timestamp] ERROR [$tag] $message',
        error: error, stackTrace: stackTrace);
  }

  static void warning(String tag, String message) {
    final timestamp = DateTime.now().toIso8601String();
    _output('[$timestamp] WARN [$tag] $message');
  }
}
