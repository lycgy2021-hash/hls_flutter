import 'package:get_storage/get_storage.dart';

abstract class KvStore {
  Future<void> init();
  String? readString(String key);
  int? readInt(String key);
  Future<void> writeString(String key, String value);
  Future<void> writeInt(String key, int value);
  Future<void> remove(String key);
}

class GetStorageKvStore implements KvStore {
  GetStorageKvStore({this.container = 'app_storage'});

  final String container;
  GetStorage? _box;

  @override
  Future<void> init() async {
    await GetStorage.init(container);
    _box = GetStorage(container);
  }

  @override
  String? readString(String key) {
    final value = _box?.read<dynamic>(key);
    if (value is String) return value;
    return null;
  }

  @override
  int? readInt(String key) {
    final value = _box?.read<dynamic>(key);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _box?.write(key, value);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await _box?.write(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _box?.remove(key);
  }
}
