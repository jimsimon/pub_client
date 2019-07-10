import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/html_parsing_client.dart';
import 'package:pub_client/src/models.dart';
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
    Page page = await client.getPageOfPackages(0);
    for (var package in page.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.score, isNotNull);
      expect(package.packageTags, isNotNull);
      expect(package.dateUpdated, isNotNull);
    }
  });

  test("test search returns valid results with no unexpected null values",
      () async {
    Page searchResults = await client.search("bloc",
        sortBy: SortType.searchRelevance, filterBy: FilterType.web);
    for (Package package in searchResults.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.packageTags, isNotNull);
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
  });
}
