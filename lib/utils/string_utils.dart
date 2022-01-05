class StringUtils {
  static String enumName(String enumToString) {
    final List<String> paths = enumToString.split('.');
    return paths[paths.length - 1];
  }
}
