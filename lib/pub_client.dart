library pub_client;

import "package:http/http.dart";
import "package:dartson/dartson.dart";
import 'package:dartson/transformers/date_time.dart';
import "dart:async";

class PubClient {

  final Map _HEADERS = const {"Content-Type": "application/json"};

  Dartson dartson;
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

    var dartson = new Dartson.JSON();
    dartson.addTransformer(new DateTimeParser(), DateTime);
    return new PubClient._internal(dartson, httpClient, normalizedBaseApiUrl);
  }

  PubClient._internal(Dartson this.dartson, Client this.client, String this.baseApiUrl);

  static String _normalizeUrl(String url) {
    if (url.endsWith("/")) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<List<Package>> getAllPackages() async {
    var packages = [];
    var currentPage = 1;
    var totalPages = 1;
    while (currentPage <= totalPages) {
      Page page = await getPageOfPackages(currentPage);
      packages.addAll(page.packages);
      totalPages = page.pages;
      currentPage++;
    }
    return packages;
  }

  Future<Page> getPageOfPackages(pageNumber) async {
    var url = "$baseApiUrl/packages?page=$pageNumber";
    Response response = await client.get(url, headers: _HEADERS);
    if (response.statusCode >= 300) {
      throw new HttpException(response.statusCode, response.body);
    }
    Page page = dartson.decode(response.body, new Page());
    return page;
  }


  Future<FullPackage> getPackage(String name) async {
    var url = "$baseApiUrl/packages/$name";
    Response response = await client.get(url, headers: _HEADERS);
    if (response.statusCode >= 300) {
      throw new HttpException(response.statusCode, response.body);
    }
    FullPackage package = dartson.decode(response.body, new FullPackage());
    return package;
  }
}

@Entity()
class Page {
  String next_url;
  List<Package> packages;
  String prev_url;
  int pages;
}

@Entity()
class Package {
  String name;
  String url;
  String uploaders_url;
  String new_version_url;
  String version_url;
  Version latest;
}

@Entity()
class FullPackage extends Package {
  DateTime created;
  int downloads;
  List<String> uploaders;
  List<Version> versions;
}

@Entity()
class Version {
  Pubspec pubspec;
  String url;
  String archive_url;
  String version;
  String new_dartdoc_url;
  String package_url;
}

@Entity()
class Pubspec {
  Environment environment;
  String version;
  String description;
  String author;
  Map<String, String> dev_dependencies;
  Map<String, String> dependencies;
  String homepage;
  String name;
}

@Entity()
class Environment {
  String sdk;
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
