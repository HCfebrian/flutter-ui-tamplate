import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    String resultHexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      resultHexColor = 'FF$resultHexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
