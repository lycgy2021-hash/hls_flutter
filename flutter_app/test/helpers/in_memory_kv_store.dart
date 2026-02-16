import 'package:flutter_app/services/storage/kv_store.dart';

class InMemoryKvStore implements KvStore {
  final Map<String, Object> _store = <String, Object>{};

  @override
  Future<void> init() async {}

  @override
  String? readString(String key) {
    final value = _store[key];
    if (value is String) return value;
    return null;
  }

  @override
  int? readInt(String key) {
    final value = _store[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<void> writeString(String key, String value) async {
    _store[key] = value;
  }
}
