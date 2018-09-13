import "package:test/test.dart";
import "package:pub_client/pub_client.dart";
import "package:http/testing.dart";
import "package:http/http.dart";
import "dart:convert";
import "dart:io" hide HttpException;

main() {
  MockClient mockClient = new MockClient((Request request) async {
    if (request.url.path == "/api/packages") {
      var page = request.url.queryParameters["page"];
      if (page == "1") {
        var responseText = new File('./fixtures/packages-page-1.json').readAsStringSync();
        return new Response(responseText, 200);
      } else if (page == "2") {
        var responseText = new File('./fixtures/packages-page-2.json').readAsStringSync();
        return new Response(responseText, 200);
      } else if (page == "42") {
        var responseText = new File('./fixtures/packages-page-42.json').readAsStringSync();
        var responseBytes = utf8.encode(responseText);
        return new Response.bytes(responseBytes, 200);
      } else {
        return new Response("Not found", 404);
      }
    } else if (request.url.path == "/api/packages/abc123") {
      var responseText = new File('./fixtures/package-with-utf8-control-characters.json').readAsStringSync();
      return new Response(responseText, 200);
    } else if (request.url.path == "/api/packages/deps") {
      var responseText = new File('./fixtures/package-with-all-dep-types.json').readAsStringSync();
      return new Response(responseText, 200);
    }
    return new Response('', 404);
  });

  PubClient client = new PubClient(client: mockClient);;

  group("client", () {
    test("can retrieve a page of packages when a valid page number is specified", () async {
      Page page = await client.getPageOfPackages(1);
      expect(page.next_url, "https://pub.dartlang.org/api/packages?page=2");
      expect(page.packages.length, 2);
      expect(page.packages[0].name, "abc123");
      expect(page.packages[1].name, "cde456");
    });

    test("throws an exception for invalid page number when retrieving a page of packages", () async {
      expect(client.getPageOfPackages(5), throwsA(TypeMatcher<HttpException>()));
    });

    test("can retrieve all packages", () async {
      List<Package> packages = await client.getAllPackages();
      expect(packages[0].name, "abc123");
      expect(packages[1].name, "cde456");
      expect(packages[2].name, "fgh678");
      expect(packages[3].name, "xyz098");
    });

    test("can retrieve a specific package", () async {
      var package = await client.getPackage("abc123");
      var now = new DateTime.now();
      expect(now.isAfter(package.created), isTrue);
    });

    test("throws an exception for invalid package name", () async {
      expect(client.getPackage("oogooaomgdakmlkd"), throwsA(TypeMatcher<HttpException>()));
    });

    test("handles response with control characters", () async {
      Page page = await client.getPageOfPackages(42);
      expect(page.packages[0].name, "spa_router");
      expect(page.packages[0].latest.pubspec.author, "Kornel Maczyński <kornel661@gmail.com>");
    });

    test("handles all types of dependency definitions", () async {
      var package = await client.getPackage("deps");
      var dependencies = package.latest.pubspec.dependencies;

      expect(dependencies.simpleDependencies, containsPair("unittest", ">=0.9.0 <0.12.0"));

      var sdkDependencies = dependencies.sdkDependencies;
      expect(sdkDependencies.containsKey("flutter"), isTrue);
      expect(sdkDependencies["flutter"].sdk, equals("flutter"));
      expect(sdkDependencies["flutter"].version, equals("^1.0.0"));

      var complexDependencies = dependencies.complexDependencies;
      expect(complexDependencies.containsKey("transmogrify"), isTrue);
      expect(complexDependencies["transmogrify"].version, "^1.4.0");
      expect(complexDependencies["transmogrify"].hosted.name, "transmogrify");
      expect(complexDependencies["transmogrify"].hosted.url, "http://your-package-server.com");

      var gitDependencies = dependencies.gitDependencies;
      expect(gitDependencies.containsKey("kittens"), isTrue);
      expect(gitDependencies["kittens"].url, "git://github.com/jimsimon/kittens.git");

      expect(gitDependencies.containsKey("puppies"), isTrue);
      expect(gitDependencies["puppies"].url, "git://github.com/jimsimon/puppies.git");
      expect(gitDependencies["puppies"].ref, "some-branch");
      expect(gitDependencies["puppies"].path, "path/to/treats");
    });
  });
}