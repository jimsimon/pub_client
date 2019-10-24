import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/endpoints.dart';
import 'package:pub_client/src/exceptions.dart';
import 'package:pub_client/src/models.dart';

class PubHtmlParsingClient {
  static PubHtmlParsingClient _singleton = PubHtmlParsingClient._internal();
  Client client = Client();

  factory PubHtmlParsingClient() => _singleton;

  PubHtmlParsingClient._internal() {
    Endpoint.responseType = ResponseType.html;
  }

  /// Get a [FullPackage] by name.
  ///
  /// returns null if the package is not valid.
  Future<FullPackage> get(String packageName) async {
    String url;
    bool isLibraryPackage = packageName.contains("dart:");
    if (isLibraryPackage) {
      // dart library results, like dart:async, which don't have a package page.
      final libName = RegExp('dart:(.*)').firstMatch(packageName).group(1);
      url =
          "https://api.dart.dev/stable/2.5.0/dart-$libName/dart-$libName-library.html";
    } else {
      url = "${Endpoint.allPackages}/$packageName";
    }
    Response response = await client.get(url);
    bool isValidPackageResult = _validateResponse(response);

    if (!isValidPackageResult) {
      throw InvalidPackageException(packageName);
    }

    if (!isLibraryPackage) {
      final versionsDoc = await client.get("$url/versions");
      return FullPackage.fromHtml(response.body,
          versionsHtmlSource: versionsDoc.body);
    } else {
      return DartLibraryPackage(name: packageName, apiReferenceUrl: url);
    }
  }

  /// Returns all packages sorted and filtered in pages of 10 packages each.
  /// Use [pageNumber] to specify the desired page.
  /// Note: Page numbers start at 1, however page 0 and page 1 both return results for
  /// the first page. To prevent confusion, [pageNumber] 0 will not be allowed.
  /// To grab the next page in order, for convenience, [Page] has a next Page getter
  /// so that you don't need to bother keeping track.
  Future<Page> getPageOfPackages(
      {int pageNumber = 1,
      SortType sortBy = SortType.searchRelevance,
      FilterType filterBy = FilterType.all}) async {
    assert(pageNumber != 0,
        "Page number 0 is not valid. Valid page numbers start at 1.");
    String url = _getUrlFromFilterType(filterBy: filterBy);
    url += "?page=$pageNumber";
    url = _addSortParamToUrl(sortBy: sortBy, url: url);

    Response response = await client.get(url);

    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body, url: url);
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
    SortType sortBy = SortType.searchRelevance,
    FilterType filterBy = FilterType.all,
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
    url = _getUrlFromFilterType(filterBy: filterBy, query: query);

    _addSortParamToUrl(sortBy: sortBy, url: url);

    Response response = await client.get(url);

    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body, url: url);
  }

  String _getUrlFromFilterType({@required FilterType filterBy, String query}) {
    String url;
    switch (filterBy) {
      case FilterType.flutter:
        url = "${Endpoint.flutterPackages}";
        break;
      case FilterType.web:
        url = "${Endpoint.webPackages}";
        break;
      case FilterType.all:
      default:
        url = "${Endpoint.allPackages}";
        break;
    }
    if (query != null) {
      url += "?q=$query";
    }
    return url;
  }

  String _addSortParamToUrl({@required SortType sortBy, @required String url}) {
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
    return url;
  }

  bool _validateResponse(Response response) {
    final document = parse(response.body);
    final title = document.querySelector('head > title').text;
    if (title.contains('Search results for')) {
      return false;
    }
    return true;
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
