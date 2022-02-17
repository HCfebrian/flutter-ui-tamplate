import 'dart:convert';
import 'dart:math';

class StringUtils {
  static String enumName(final String enumToString) {
    final List<String> paths = enumToString.split('.');
    return paths[paths.length - 1];
  }
}


String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
