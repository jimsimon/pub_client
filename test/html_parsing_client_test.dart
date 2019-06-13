import 'package:pub_client/src/html_parsing_client.dart';
import 'package:test/test.dart';

import '../lib/pub_client.dart';

void main() {
  PubHtmlParsingClient client = PubHtmlParsingClient();

  test("test", () async {
    FullPackage blocPackage = await client.get("bloc");
  });
}
