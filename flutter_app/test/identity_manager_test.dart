import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/services/identity/identity_manager.dart';

import 'helpers/in_memory_kv_store.dart';

void main() {
  group('IdentityManager', () {
    test('did stays stable across re-init', () async {
      final store = InMemoryKvStore();
      final manager1 = IdentityManager(kvStore: store, nowMs: () => 1000);
      await manager1.init();
      final did1 = await manager1.getDid();

      final manager2 = IdentityManager(kvStore: store, nowMs: () => 2000);
      await manager2.init();
      final did2 = await manager2.getDid();

      expect(did1, isNotEmpty);
      expect(did1, did2);
      expect((await manager2.getActorId()).startsWith('a_'), true);
    });

    test('actor_id prefix repair triggers session reset', () async {
      final store = InMemoryKvStore();
      await store.writeString(didKey, 'did_fixed_123');
      await store.writeString(actorIdKey, 'polluted_actor_id');
      await store.writeString(sessionIdKey, 's_old');
      await store.writeInt(sessionCreatedAtKey, 1234);

      final manager = IdentityManager(kvStore: store, nowMs: () => 2000);
      await manager.init();

      final repairedActor = await manager.getActorId();
      final session = await manager.getSessionId();

      expect(repairedActor, startsWith('a_'));
      expect(repairedActor, isNot('a_did_fixed_123'));
      expect(session, isNull);
    });

    test('session TTL expiry clears session', () async {
      final store = InMemoryKvStore();
      await store.writeString(didKey, 'did_fixed_abc');
      await store.writeString(actorIdKey, 'a_fixed_abc');

      int now = 1000;
      final manager = IdentityManager(kvStore: store, nowMs: () => now);
      await manager.init();
      await manager.setSession('s_live');
      now = 1000 + sessionTtlMsDefault + 1;
      final session = await manager.getSessionId();

      expect(session, isNull);
      expect(store.readString(sessionIdKey), isNull);
      expect(store.readInt(sessionCreatedAtKey), isNull);
    });
  });
}
