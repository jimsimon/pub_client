import "package:unittest/unittest.dart";
import "package:pub_client/pub_client.dart";
import "package:http/testing.dart";
import "package:http/http.dart";

main() {
  PubClient client;

  group("client", () {
    test("can retrieve a page of packages when a valid page number is specified", () async {
      MockClient mockClient = new MockClient((Request request) {
        if (request.url.path == "/api/packages") {
          return new Response("{}", 200);
        }
        return new Response("", 404);
      });
      client = new PubClient(client: mockClient);
      Map packages = await client.getPageOfPackages(1);
      expect(packages["name"], equals("test package"));
    });
  });
}