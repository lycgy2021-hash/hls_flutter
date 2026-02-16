import 'env/env_dev.dart';
import 'env/env_prod.dart';
import 'env/env_staging.dart';
import 'env/env_values.dart';

class AppConfig {
  static const String _appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static EnvValues get currentEnv {
    switch (_appEnv) {
      case 'prod':
        return prodEnv;
      case 'staging':
        return stagingEnv;
      case 'dev':
      default:
        return devEnv;
    }
  }

  static String get envLabel => currentEnv.label;
  static String get apiBase => currentEnv.apiBase;
  static String get apiNewBase => currentEnv.apiNewBase;
  static String get algoBase => currentEnv.algoBase;
  static String get longVideoBase => currentEnv.longVideoBase;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sessionTtl = Duration(minutes: 30);
}
