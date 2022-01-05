import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/contract_repo/local_pref_abs.dart';

class SharedPrefImpl implements LocalPrefAbs {
  final SharedPreferences sharedPref;

  SharedPrefImpl({required this.sharedPref});

  @override
  Future setBool({required String key, required bool value}) {
    return sharedPref.setBool(key, value);
  }

  @override
  Future<bool?> getBool({required String key}) async {
    return sharedPref.getBool(key);
  }

  @override
  Future setDouble({required String key, required double value}) {
    return sharedPref.setDouble(key, value);
  }

  @override
  Future<double?> getDouble({required String key}) async {
    return sharedPref.getDouble(key);
  }

  @override
  Future setString({required String key, required String value}) {
    return sharedPref.setString(key, value);
  }

  @override
  Future<String?> getString({required String key}) async {
    return sharedPref.getString(key);
  }

  @override
  Future setInt({required String key, required int value}) {
    return sharedPref.setInt(key, value);
  }

  @override
  Future<int?> getInt({required String key}) async {
    return sharedPref.getInt(key);
  }

  @override
  Future setStringList({required String key, required List<String> value}) {
    return sharedPref.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList({required String key}) async {
    return sharedPref.getStringList(key);
  }
}
