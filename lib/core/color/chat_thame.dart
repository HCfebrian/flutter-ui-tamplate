import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_flutter/get_it.dart';

class ChatThemeCustom {
  static Color barColor = Colors.redAccent;
  static Color barContentColor = Colors.black87;
  static Color fabColor = Colors.black87;

  //chat bubble theme
  static Color peopleBubbleColor = Colors.white12;
  static Color peopleBubbleTextColor = Colors.black54;

  static Color getBarColor() {
    final SharedPreferences sharedPreferences = getIt();

    final result = sharedPreferences.getInt('barColor');
    log("shared pref result $result");
    if (result != null) {
      return Color(result);
    } else {
      return barColor;
    }
  }

  void setBarColor({required Color color}) {
    final SharedPreferences sharedPreferences = getIt();
    sharedPreferences.setInt('barColor', color.value);
  }

  static Color getBarContentColor() {
    final SharedPreferences sharedPreferences = getIt();

    final result = sharedPreferences.getInt('barContentColor');
    log("shared pref result $result");
    if (result != null) {
      return Color(result);
    } else {
      return barContentColor;
    }
  }

  Future setBarContentColor({required Color color}) async {
    final SharedPreferences sharedPreferences = getIt();
    await sharedPreferences.setInt('barContentColor', color.value);
  }

  static Color getFabColor() {
    final SharedPreferences sharedPreferences = getIt();

    final result = sharedPreferences.getInt('fabColor');
    log("shared pref result $result");
    if (result != null) {
      return Color(result);
    } else {
      return fabColor;
    }
  }

  Future setFabColor({required Color color}) async {
    final SharedPreferences sharedPreferences = getIt();
    await sharedPreferences.setInt('fabColor', color.value);
  }
}
