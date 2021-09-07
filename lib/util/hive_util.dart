import 'package:hive_flutter/adapters.dart';

class HiveUtils {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('user-admin');
  }

  static Future<void> set(String key, dynamic value) {
    return _box.put(key, value);
  }

  static get(String key) {
    return _box.get(key);
  }

  static remove(String key) {
    return _box.delete(key);
  }

  static removeAll() {
    return _box.deleteAll(_box.keys);
  }
}
