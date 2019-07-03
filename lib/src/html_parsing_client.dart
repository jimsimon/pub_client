import 'package:http/http.dart';
import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/endpoints.dart';
import 'package:pub_client/src/models.dart';

class PubHtmlParsingClient {
  Client client = Client();

  PubHtmlParsingClient() {
    Endpoint.responseType = ResponseType.html;
  }

  Future<FullPackage> get(String packageName) async {
    String url = "${Endpoint.packages}/$packageName";
    Response response = await client.get(url);
    return FullPackage.fromHtml(response.body);
  }

  Future<Page> getPageOfPackages(int pageNumber) async {
    String url = "${Endpoint.packages}?page=$pageNumber";
    Response response = await client.get(url);

    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body);
  }

  Future<Page> search(String query, {SortType sortBy}) async {
    String url = "${Endpoint.packages}?q=$query";
    switch (sortBy) {
      case SortType.searchRelevance:
        break;
      case SortType.overAllScore:
        url += "&sort=top";
        break;
      case SortType.recentlyUpdated:
        url += "&sort=updated";
        break;
      case SortType.newestPackage:
        url += "&sort=created";
        break;
      case SortType.popularity:
        url += "&sort=popularity";
        break;
      default:
        break;
    }

    Response response = await client.get(url);

    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body);
  }
}

enum SortType {
  /// Packages are sorted by their updated time.
  searchRelevance,

  /// Packages are sorted by the overall score.
  overAllScore,

  /// Packages are sorted by their updated time.
  recentlyUpdated,

  /// Packages are sorted by their created time.
  newestPackage,

  /// Packages are sorted by their popularity score.
  popularity
}
