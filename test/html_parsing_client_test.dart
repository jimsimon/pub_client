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
  });
}
