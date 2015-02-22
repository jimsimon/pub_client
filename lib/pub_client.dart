library pub_client;

//import "dart:io";
import "package:http/http.dart";
import "dart:async";
import "dart:convert";

class PubClient {

  final Map _HEADERS = const {"Content-Type": "application/json"};

  Client client = new Client();
  String baseApiUrl;

  PubClient({Client client: null, baseApiUrl: "https://pub.dartlang.org/api"}) {
    if (client != null) {
      this.client = client;
    }
    this.baseApiUrl = _normalizeUrl(baseApiUrl);
  }

  _normalizeUrl(String url) {
    if (url.endsWith("/")) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<List<Map>> getAllPackages() async {
    var packages = [];
    var currentPage = 1;
    var totalPages = 1;
    while (currentPage <= totalPages) {
      var response = await getPageOfPackages(currentPage);
      packages.addAll(response["packages"]);
      totalPages = response["pages"];
      currentPage++;
    }
    print("${packages.length} packages found");
    return packages;
  }

  Future<Map> getPageOfPackages(pageNumber) async {
    var url = "$baseApiUrl/packages?page=$pageNumber";
    print("Requesting data from $url");
    Response response = await client.get(url, headers: _HEADERS);
    Map jsonResponse = JSON.decode(response.body);
    return jsonResponse;
  }
}
