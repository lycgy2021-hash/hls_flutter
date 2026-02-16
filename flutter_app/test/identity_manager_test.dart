import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/services/identity_manager.dart';
import 'package:flutter_app/services/storage_service.dart';

void main() {
  group('IdentityManager', () {
    test('did stays stable across re-init', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final storage1 = StorageService();
      await storage1.init();
      final manager1 = IdentityManager(storage1);
      await manager1.init();
      final did1 = manager1.did;

      final storage2 = StorageService();
      await storage2.init();
      final manager2 = IdentityManager(storage2);
      await manager2.init();
      final did2 = manager2.did;

      expect(did1, isNotEmpty);
      expect(did1, did2);
      expect(manager2.actorId.startsWith('a_'), true);
    });

    test('session rotates when ttl expired', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'did': 'did_fixed',
        'hls_actor_id': 'a_fixed',
        'hls_session_id': 's_old',
        'hls_session_created_at': 0,
      });

      final storage = StorageService();
      await storage.init();
      final manager = IdentityManager(storage);
      await manager.init();

      expect(manager.sessionId, isNot('s_old'));
    });
  });
}
