library pub_client;

import "package:http/http.dart";
import "dart:async";
import "dart:convert";
import "package:pub_client/src/models.dart";

export "package:pub_client/src/models.dart";

class PubClient {
  final Map _HEADERS = const <String,String>{"Content-Type": "application/json"};

  Client client;
  String baseApiUrl;

  factory PubClient({Client client: null, baseApiUrl: "https://pub.dartlang.org/api"}) {
    Client httpClient;
    if (client != null) {
      httpClient = client;
    } else {
      httpClient = new Client();
    }
    var normalizedBaseApiUrl = _normalizeUrl(baseApiUrl);

    return new PubClient._internal(httpClient, normalizedBaseApiUrl);
  }

  PubClient._internal(Client this.client, String this.baseApiUrl);

  static String _normalizeUrl(String url) {
    if (url.endsWith("/")) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<List<Package>> getAllPackages() async {
    var packages = <Package>[];

    var currentPage = 1;
    var nextPageExists = true;
    while (nextPageExists) {
      Page page = await getPageOfPackages(currentPage);
      packages.addAll(page.packages);
      currentPage++;
      if (page.next_url == null) {
        nextPageExists = false;
      }
    }
    return packages;
  }

  Future<Page> getPageOfPackages(pageNumber) async {
    var url = "$baseApiUrl/packages?page=$pageNumber";
    Response response = await client.get(url, headers: _HEADERS);
    if (response.statusCode >= 300) {
      throw new HttpException(response.statusCode, response.body);
    }
    Page page = Page.fromJson(json.decode(response.body));
    return page;
  }

  Future<FullPackage> getPackage(String name) async {
    var url = "$baseApiUrl/packages/$name";
    Response response = await client.get(url, headers: _HEADERS);
    if (response.statusCode >= 300) {
      throw new HttpException(response.statusCode, response.body);
    }
    FullPackage package = FullPackage.fromJson(json.decode(response.body));
    return package;
  }
}

class HttpException implements Exception {
  int status;
  String message;
  HttpException(int this.status, [String this.message]);

  String toString() {
    String stringRepresentation =  "$status";
    if (message != null) {
      stringRepresentation += ": $message";
    }
    return stringRepresentation;
  }
}
