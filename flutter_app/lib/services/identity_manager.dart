import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class IdentityManager {
  IdentityManager(this._storage);

  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  static const String _didKey = 'did';
  static const String _actorIdKey = 'hls_actor_id';
  static const String _sessionIdKey = 'hls_session_id';
  static const String _sessionCreatedAtKey = 'hls_session_created_at';

  late String _did;
  late String _actorId;
  late String _sessionId;

  Future<void> init() async {
    _did = _storage.getString(_didKey) ?? _uuid.v4();
    await _storage.setString(_didKey, _did);

    final storedActorId = _storage.getString(_actorIdKey);
    _actorId = _normalizeActorId(storedActorId);
    await _storage.setString(_actorIdKey, _actorId);

    _sessionId = await _resolveSessionId();
    AppLogger.info('Identity initialized', data: {
      'did': _did,
      'actor_id': _actorId,
      'session_id': _sessionId,
    });
  }

  String get did => _did;
  String get actorId => _actorId;
  String get sessionId => _sessionId;

  Future<void> setActorIdIfValid(String? serverActorId) async {
    if (serverActorId == null || serverActorId.isEmpty) return;
    if (!serverActorId.startsWith('a_')) return;
    _actorId = serverActorId;
    await _storage.setString(_actorIdKey, _actorId);
  }

  Future<void> refreshSessionIfExpired() async {
    final createdAt = _storage.getInt(_sessionCreatedAtKey);
    if (createdAt == null) {
      _sessionId = await _createNewSession();
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - createdAt > AppConfig.sessionTtl.inMilliseconds) {
      await _storage.remove(_sessionIdKey);
      await _storage.remove(_sessionCreatedAtKey);
      _sessionId = await _createNewSession();
    }
  }

  Future<void> resetSession() async {
    await _storage.remove(_sessionIdKey);
    await _storage.remove(_sessionCreatedAtKey);
    _sessionId = await _createNewSession();
  }

  Map<String, String> buildDefaultHeaders() {
    return <String, String>{
      'X-Actor-ID': actorId,
      'X-DID': did,
    };
  }

  String _normalizeActorId(String? actorId) {
    if (actorId != null && actorId.startsWith('a_')) {
      return actorId;
    }
    return 'a_${_did.replaceAll('-', '')}';
  }

  Future<String> _resolveSessionId() async {
    await refreshSessionIfExpired();
    final existing = _storage.getString(_sessionIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    return _createNewSession();
  }

  Future<String> _createNewSession() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newSession =
        's_${DateTime.now().millisecondsSinceEpoch ~/ 1000}_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';
    await _storage.setString(_sessionIdKey, newSession);
    await _storage.setInt(_sessionCreatedAtKey, timestamp);
    return newSession;
  }
}
