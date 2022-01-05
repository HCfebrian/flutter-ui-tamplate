class StringUtils {
  static String enumName(final String enumToString) {
    final List<String> paths = enumToString.split('.');
    return paths[paths.length - 1];
  }
}
