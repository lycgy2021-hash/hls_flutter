class AppConfig {
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://192.168.0.107:8080',
  );

  static const String apiNewBase = String.fromEnvironment(
    'API_NEW_BASE',
    defaultValue: 'http://192.168.0.107:8099',
  );

  static const String algoBase = String.fromEnvironment(
    'ALGO_BASE',
    defaultValue: 'http://192.168.0.107:8083',
  );

  static const String longVideoBase = String.fromEnvironment(
    'LONG_VIDEO_BASE',
    defaultValue: 'http://192.168.0.107:8081',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sessionTtl = Duration(minutes: 30);
}
