import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/html_parsing_client.dart';
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

    test("Page from HTML returns a valid Page with no null values", () async {
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
  });
}
