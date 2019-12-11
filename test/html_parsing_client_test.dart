import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/exceptions.dart';
import 'package:pub_client/src/html_parsing_client.dart';
import 'package:pub_client/src/models.dart';
import 'package:pub_semver/pub_semver.dart' as semver;
import 'package:test/test.dart';

void main() {
  PubHtmlParsingClient client = PubHtmlParsingClient();

  group("test package scores are found sucessfully", () {
    test("test 'aiframework' score is non-null", () async {
      FullPackage aiFrameWork = await client.get("aiframework");
      expect(aiFrameWork.score, isNotNull);
    });

    test("test 'add_to_calendar' score is non-null", () async {
      FullPackage addToCalendar = await client.get("add_to_calendar");
      expect(addToCalendar.score, isNotNull);
    });

    test("test 'aiframework' score is non-null", () async {
      FullPackage potatoHelper = await client.get("potato_helper");
      expect(potatoHelper.score, isNotNull);
    });
  });

  test("Page from HTML returns a valid Page with no unexpected null values",
      () async {
    Page page = await client.getPageOfPackages(pageNumber: 1);
    for (var package in page.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.score, isNotNull);
      expect(package.platformCompatibilityTags, isNotNull);
      expect(package.dateUpdated, isNotNull);
    }
  });
  test("test getPageOfPackages", () async {
    Page sortedPageByPopularity = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.popularity, filterBy: FilterType.web);
    Page sortedPageByScore = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.overAllScore);
    Page sortedPageByRecentlyUpdated = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.recentlyUpdated);
    Page sortedPageByCreated = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.newestPackage);

    expect(sortedPageByPopularity.url, contains('sort=popularity'));
    expect(sortedPageByPopularity.url, contains('sort=popularity'));
    expect(sortedPageByPopularity.packages, isNotEmpty);

    expect(sortedPageByRecentlyUpdated.url, contains('sort=updated'));
    expect(sortedPageByRecentlyUpdated.packages, isNotEmpty);

    expect(sortedPageByCreated.url, contains('sort=created'));
    expect(sortedPageByCreated.packages, isNotEmpty);

    expect(sortedPageByScore.url, contains('sort=top'));
    expect(sortedPageByScore.packages, isNotEmpty);
  });

  test("test search returns valid results with no unexpected null values",
      () async {
    Page searchResults = await client.search("bloc",
        sortBy: SortType.searchRelevance, filterBy: FilterType.web);
    for (Package package in searchResults.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.platformCompatibilityTags, isNotNull);
      expect(package.packageUrl, isNotNull);
      expect(package.dateUpdated, isNotNull);
    }
  });

  test("test Page.nextPage returns a valid Page", () async {
    Page searchResults = await client.search("bloc",
        sortBy: SortType.searchRelevance, filterBy: FilterType.flutter);
    Page secondPage = await searchResults.nextPage;
    expect(secondPage, isNotNull);
  });

  group("test advanced search", () {
    test('test exact phrase', () async {
      Page searchResults = await client.search("html");

      // TODO: (ThinkDigitalSoftware) wait until we support API results before testing this
      // as some results show up only because of the search string being present
      // in API results.
    });

    test('test prefix', () async {
      Page searchResults = await client.search("html", isPrefix: true);
      for (Package package in searchResults) {
        expect(package.name, startsWith('html'));
      }
    });

    test('Request for an invalid package throws an InvalidPackageException',
        () {
      expect(
        () async => await client.get('someInvalidPackage'),
        throwsA(TypeMatcher<InvalidPackageException>()),
      );
    });
    test('package can be fetched with no errors', () async {
      expect(() async => await client.get('url_launcher'), returnsNormally);
    });
  });

  test('FullPackage toJson and fromJson return no errors', () async {
    final FullPackage urlLauncher = await client.get('url_launcher');
    final json = urlLauncher.toJson();
    final FullPackage urlLauncherFromJson = FullPackage.fromJson(json);
    expect(urlLauncher, urlLauncherFromJson);
  });

  test('Package toJson and fromJson return no errors', () async {
    final FullPackage urlLauncherFull = await client.get('url_launcher');
    final Package urlLauncherPackage = urlLauncherFull.toPackage;
    final json = urlLauncherPackage.toJson();
    final Package urlLauncherPackageFromJson = Package.fromJson(json);
    expect(urlLauncherPackage, urlLauncherPackageFromJson);
  });
  test('Uploaders display properly', () async {
    final package = await client.get('nb_map');
    expect(package.uploaders, isNotNull);
  });

  test('search results returns packages with no errors', () async {
    final results = await client.search('live video');
    final nonSdkPackages =
        results.where((package) => !package.name.contains('dart:'));
    for (Package package in nonSdkPackages) {
      // filtering out these two values because they're not supposed to be provided in a page search.
      final unacceptableNullValues = package.nullValues
          .where((value) => value != 'uploaders' && value != 'versionUrl');
      expect(
        unacceptableNullValues,
        isEmpty,
        reason:
            "Package: ${package.name}\nNull values: ${unacceptableNullValues}",
      );
    }
  });

  test('something', () async {
    FullPackage deepLinkNavigation = await client.get('deep_link_navigation');
    expect(true, isTrue);
  });

  test("package with non-standard build versions parse correctly", () async {
    var version = semver.Version(3, 0, 2, build: 'dart2');
    FullPackage overReact = await client.get('over_react');
    FullPackage imagePicker = await client.get('image_picker');
    print('');
  });

  test('AnalysisTab contains individual values for each variable', () async {
    final FullPackage fxpoi = await client.get('fxpoi');
  });
}
