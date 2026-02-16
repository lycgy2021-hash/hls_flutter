import 'package:uuid/uuid.dart';

import 'package:flutter_app/services/storage/kv_store.dart';

const String didKey = 'did';
const String actorIdKey = 'hls_actor_id';
const String sessionIdKey = 'hls_session_id';
const String sessionCreatedAtKey = 'hls_session_created_at';
const int sessionTtlMsDefault = 7 * 24 * 3600 * 1000;

class IdentityManager {
  IdentityManager({
    required KvStore kvStore,
    Uuid? uuid,
    int Function()? nowMs,
  })  : _kvStore = kvStore,
        _uuid = uuid ?? const Uuid(),
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final KvStore _kvStore;
  final Uuid _uuid;
  final int Function() _nowMs;

  Future<void> init() async {
    await _kvStore.init();
    await getDid();
    await getActorId();
    await getSessionId();
  }

  Future<String> getDid() async {
    final existing = _kvStore.readString(didKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _generateDid();
    await _kvStore.writeString(didKey, generated);
    return generated;
  }

  Future<String> getActorId() async {
    final existing = _kvStore.readString(actorIdKey);
    if (existing == null || existing.isEmpty) {
      final generated = _generateActorId();
      await _kvStore.writeString(actorIdKey, generated);
      return generated;
    }

    if (!existing.startsWith('a_')) {
      final repaired = _generateActorId();
      await _kvStore.writeString(actorIdKey, repaired);
      await clearSession();
      return repaired;
    }

    return existing;
  }

  Future<void> setActorId(String value) async {
    if (value.isEmpty) return;
    if (!value.startsWith('a_')) {
      final repaired = _generateActorId();
      await _kvStore.writeString(actorIdKey, repaired);
      await clearSession();
      return;
    }
    await _kvStore.writeString(actorIdKey, value);
  }

  Future<String?> getSessionId() async {
    final sessionId = _kvStore.readString(sessionIdKey);
    final createdAt = _kvStore.readInt(sessionCreatedAtKey);

    if (sessionId == null || sessionId.isEmpty || createdAt == null) {
      return null;
    }

    if (_nowMs() - createdAt > sessionTtlMsDefault) {
      await clearSession();
      return null;
    }

    return sessionId;
  }

  Future<void> setSession(String sessionId) async {
    await _kvStore.writeString(sessionIdKey, sessionId);
    await _kvStore.writeInt(sessionCreatedAtKey, _nowMs());
  }

  Future<void> clearSession() async {
    await _kvStore.remove(sessionIdKey);
    await _kvStore.remove(sessionCreatedAtKey);
  }

  Future<void> ensureDid(String? did) async {
    if (did == null || did.isEmpty) return;
    final existing = _kvStore.readString(didKey);
    if (existing == null || existing.isEmpty) {
      await _kvStore.writeString(didKey, did);
    }
  }

  String _generateDid() {
    return _uuid.v4();
  }

  String _generateActorId() {
    return 'a_${_generateDid()}';
  }
}
