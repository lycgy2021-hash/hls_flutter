import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, {Object? data}) {
    developer.log(message, name: 'APP', error: data);
  }

  static void warn(String message, {Object? data}) {
    developer.log(message, name: 'APP_WARN', error: data);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message,
        name: 'APP_ERROR', error: error, stackTrace: stackTrace);
  }
}
