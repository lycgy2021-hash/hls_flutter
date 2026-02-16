import 'dart:developer' as developer;

class AppLogger {
  AppLogger._(this._tag);

  final String _tag;

  static AppLogger tag(String tag) => AppLogger._(tag);

  static void info(String message, {Object? data}) {
    tag('APP').logInfo(message, data: data);
  }

  static void warn(String message, {Object? data}) {
    tag('APP').logWarn(message, data: data);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    tag('APP').logError(message, error: error, stackTrace: stackTrace);
  }

  void logInfo(String message, {Object? data}) {
    developer.log(message, name: _tag, error: data);
  }

  void logWarn(String message, {Object? data}) {
    developer.log(message, name: '$_tag/WARN', error: data);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message,
        name: '$_tag/ERROR', error: error, stackTrace: stackTrace);
  }
}
