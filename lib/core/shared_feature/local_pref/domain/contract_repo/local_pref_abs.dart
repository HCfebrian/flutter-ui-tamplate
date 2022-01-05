abstract class LocalPrefAbs {
  Future setString({required String key, required String value});

  Future<String?> getString({required String key});

  Future setBool({required String key, required bool value});

  Future<bool?> getBool({required String key});

  Future setDouble({required String key, required double value});

  Future<double?> getDouble({required String key});

  Future setStringList({required String key, required List<String> value});

  Future getStringList({
    required String key,
  });

  Future setInt({required String key, required int value});

  Future<int?> getInt({
    required String key,
  });
}
