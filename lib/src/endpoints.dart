class Endpoint {
  static ResponseType responseType;

  static String get baseUrl {
    switch (responseType) {
      case ResponseType.api:
        {
          return "https://pub.dev/api";
        }
      case ResponseType.html:
        {
          return "https://pub.dev/";
        }
      default:
        return "https://pub.dev/api";
    }
  }

  /// the endpoint for all packages alphabetically
  static String packages = "${baseUrl}/packages";
  static String documentation = "${baseUrl}/documentation";
}

enum ResponseType { api, html }
