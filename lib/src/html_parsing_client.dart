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
    String url = "${Endpoint.allPackages}/$packageName";
    Response response = await client.get(url);
    return FullPackage.fromHtml(response.body);
  }

  Future<Page> getPageOfPackages(int pageNumber) async {
    String url = "${Endpoint.allPackages}?page=$pageNumber";
    Response response = await client.get(url);

    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body);
  }

  /// We support the following search expressions:
  /// ∙ "exact phrase": By default, when you perform a search,
  ///   the results include packages with similar phrases.
  ///   When a phrase is inside quotes,
  ///   you'll see only those packages that contain exactly the specified phrase.
  /// ∙ package:prefix: Searches for packages that begin with prefix.
  ///     Use this feature to find packages in the same framework.
  /// ∙ dependency:package_name: Searches for packages that reference package_name in their pubspec.
  /// ∙ <strike>dependency*:package_name: Searches for packages that depend on package_name
  ///     (as direct, dev, or transitive dependencies).</strike> Not yet supported.
  /// ∙ email:user@example.com: Search for packages where either the author or the uploader has the specified e-mail address.
  ///
  /// Note: Only one search qualifier can be used at a time. I.E. You cannot search for a prefix and an exactPhrase in the same query.
  /// this is a limitation of pub.dev.
  Future<Page> search(
    String query, {
    SortType sortBy,
    FilterType filterBy,
    bool isExactPhrase = false,
    bool isPrefix = false,
    bool isDependency = false,
    bool isEmail = false,
  }) async {
    var trueQualifiers = [isExactPhrase, isPrefix, isDependency, isEmail]
        .where((qualifier) => qualifier)
        .length;
    assert(
        trueQualifiers < 2, "Only one search qualifier can be used at a time.");
    String url;
    if (isExactPhrase) {
      query = '\"$query\"';
    }
    if (isPrefix) {
      query = 'package:$query';
    }
    if (isDependency) {
      query = 'dependency:$query';
    }
    if (isEmail) {
      query = 'email:$query';
    }
    switch (filterBy) {
      case FilterType.flutter:
        url = "${Endpoint.flutterPackages}?q=$query";
        break;
      case FilterType.web:
        url = "${Endpoint.webPackages}?q=$query";
        break;
      case FilterType.all:
      default:
        url = "${Endpoint.allPackages}?q=$query";
        break;
    }

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

enum FilterType { flutter, web, all }
