import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/config/app_config.dart';

void main() {
  test('app config has valid environment and base urls', () {
    expect(AppConfig.envLabel, isNotEmpty);
    expect(AppConfig.apiBase, isNotEmpty);
    expect(AppConfig.apiNewBase, isNotEmpty);
    expect(AppConfig.algoBase, isNotEmpty);
    expect(AppConfig.longVideoBase, isNotEmpty);
  });
}
