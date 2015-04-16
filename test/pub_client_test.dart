import "package:unittest/unittest.dart";
import "package:pub_client/pub_client.dart";
import "package:http/testing.dart";
import "package:http/http.dart";
import "dart:convert";

main() {

  MockClient mockClient = new MockClient((Request request) {
    if (request.url.path == "/api/packages") {
      var page = request.url.queryParameters["page"];
      if (page == "1") {
        var responseText = '''
            {"next_url": "https://pub.dartlang.org/api/packages?page=2", "packages": [
              {"name": "abc123", "url": "https://pub.dartlang.org/api/packages/abc123", "uploaders_url": "https://pub.dartlang.org/api/packages/abc123/uploaders", "new_version_url": "https://pub.dartlang.org/api/packages/abc123/versions/new", "version_url": "https://pub.dartlang.org/api/packages/abc123/versions/{version}", "latest": {"pubspec": {"environment": {"sdk": ">=1.0.0 <2.0.0"}, "version": "1.3.5", "description": "abc123 library", "author": "Abc Team <abc@123.org>", "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"}, "homepage": "http://github.com/dart-lang/abc123", "name": "abc123"}, "url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5", "archive_url": "https://pub.dartlang.org/packages/abc123/versions/1.3.5.tar.gz", "version": "1.3.5", "new_dartdoc_url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5/new_dartdoc", "package_url": "https://pub.dartlang.org/api/packages/abc123"}},
              {"name": "cde456", "url": "https://pub.dartlang.org/api/packages/cde456", "uploaders_url": "https://pub.dartlang.org/api/packages/cde456/uploaders", "new_version_url": "https://pub.dartlang.org/api/packages/cde456/versions/new", "version_url": "https://pub.dartlang.org/api/packages/cde456/versions/{version}", "latest": {"pubspec": {"environment": {"sdk": ">=1.0.0 <2.0.0"}, "version": "1.3.5", "description": "cde456 library", "author": "Abc Team <abc@123.org>", "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"}, "homepage": "http://github.com/dart-lang/cde456", "name": "cde456"}, "url": "https://pub.dartlang.org/api/packages/cde456/versions/1.3.5", "archive_url": "https://pub.dartlang.org/packages/cde456/versions/1.3.5.tar.gz", "version": "1.3.5", "new_dartdoc_url": "https://pub.dartlang.org/api/packages/cde456/versions/1.3.5/new_dartdoc", "package_url": "https://pub.dartlang.org/api/packages/cde456"}}
            ], "prev_url": null, "pages": 2}
          ''';
        return new Response(responseText, 200);
      } else if (page == "2") {
        var responseText = '''
            {"next_url": "https://pub.dartlang.org/api/packages?page=2", "packages": [
              {"name": "fgh678", "url": "https://pub.dartlang.org/api/packages/abc123", "uploaders_url": "https://pub.dartlang.org/api/packages/abc123/uploaders", "new_version_url": "https://pub.dartlang.org/api/packages/abc123/versions/new", "version_url": "https://pub.dartlang.org/api/packages/abc123/versions/{version}", "latest": {"pubspec": {"environment": {"sdk": ">=1.0.0 <2.0.0"}, "version": "1.3.5", "description": "abc123 library", "author": "Abc Team <abc@123.org>", "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"}, "homepage": "http://github.com/dart-lang/abc123", "name": "abc123"}, "url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5", "archive_url": "https://pub.dartlang.org/packages/abc123/versions/1.3.5.tar.gz", "version": "1.3.5", "new_dartdoc_url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5/new_dartdoc", "package_url": "https://pub.dartlang.org/api/packages/abc123"}},
              {"name": "xyz098", "url": "https://pub.dartlang.org/api/packages/cde456", "uploaders_url": "https://pub.dartlang.org/api/packages/cde456/uploaders", "new_version_url": "https://pub.dartlang.org/api/packages/cde456/versions/new", "version_url": "https://pub.dartlang.org/api/packages/cde456/versions/{version}", "latest": {"pubspec": {"environment": {"sdk": ">=1.0.0 <2.0.0"}, "version": "1.3.5", "description": "cde456 library", "author": "Abc Team <abc@123.org>", "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"}, "homepage": "http://github.com/dart-lang/cde456", "name": "cde456"}, "url": "https://pub.dartlang.org/api/packages/cde456/versions/1.3.5", "archive_url": "https://pub.dartlang.org/packages/cde456/versions/1.3.5.tar.gz", "version": "1.3.5", "new_dartdoc_url": "https://pub.dartlang.org/api/packages/cde456/versions/1.3.5/new_dartdoc", "package_url": "https://pub.dartlang.org/api/packages/cde456"}}
            ], "prev_url": null, "pages": 2}
          ''';
        return new Response(responseText, 200);
      } else if (page == "42") {
        var responseText = '''
        {"next_url": "https://pub.dartlang.org/api/packages?page=2", "packages": [
        {
         "name":"spa_router",
         "url":"https://pub.dartlang.org/api/packages/spa_router",
         "uploaders_url":"https://pub.dartlang.org/api/packages/spa_router/uploaders",
         "new_version_url":"https://pub.dartlang.org/api/packages/spa_router/versions/new",
         "version_url":"https://pub.dartlang.org/api/packages/spa_router/versions/{version}",
         "latest":{
            "pubspec":{
               "transformers":[
                  {
                     "polymer":{
                        "entry_points":[
                           "example/index.html",
                           "example/transitions.html"
                        ]
                     }
                  }
               ],
               "description":"Routing element for HTML5 single page applications (declarative syntax :-)) written in Polymer.dart.\n",
               "author":"Kornel Maczy\u0144ski <kornel661@gmail.com>",
               "environment":{
                  "sdk":">=1.8.5"
               },
               "version":"0.1.2+1",
               "dependencies":{
                  "template_binding":"^0.14.0+2",
                  "polymer":"^0.16.0+7",
                  "core_elements":"^0.6.1+2",
                  "browser":"^0.10.0+2"
               },
               "dev_dependencies":{
                  "unittest":"^0.11.5+4"
               },
               "homepage":"https://github.com/kornel661/spa-router",
               "name":"spa_router"
            },
            "url":"https://pub.dartlang.org/api/packages/spa_router/versions/0.1.2%2B1",
            "archive_url":"https://pub.dartlang.org/packages/spa_router/versions/0.1.2%2B1.tar.gz",
            "version":"0.1.2+1",
            "new_dartdoc_url":"https://pub.dartlang.org/api/packages/spa_router/versions/0.1.2%2B1/new_dartdoc",
            "package_url":"https://pub.dartlang.org/api/packages/spa_router"
         }
      }], "prev_url": null, "pages": 1}
        ''';
        var responseBytes = UTF8.encode(responseText);
        return new Response.bytes(responseBytes, 200);
      } else {
        return new Response("Not found", 404);
      }
    } else if (request.url.path == "/api/packages/abc123") {
      return new Response('{"name": "abc123", "created": "2013-07-16T00:21:54.360590", "url": "https://pub.dartlang.org/api/packages/abc123", "uploaders_url": "https://pub.dartlang.org/api/packages/abc123/uploaders", "new_version_url": "https://pub.dartlang.org/api/packages/abc123/versions/new", "version_url": "https://pub.dartlang.org/api/packages/abc123/versions/{version}", "latest": {"pubspec": {"environment": {"sdk": ">=1.0.0 <2.0.0"}, "version": "1.3.5", "description": "abc123 library", "author": "Abc Team <abc@123.org>", "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"}, "homepage": "http://github.com/dart-lang/abc123", "name": "abc123"}, "url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5", "archive_url": "https://pub.dartlang.org/packages/abc123/versions/1.3.5.tar.gz", "version": "1.3.5", "new_dartdoc_url": "https://pub.dartlang.org/api/packages/abc123/versions/1.3.5/new_dartdoc", "package_url": "https://pub.dartlang.org/api/packages/abc123"}}', 200);
    }
    return new Response('', 404);
  });

  PubClient client = new PubClient(client: mockClient);;

  group("client", () {
    test("can retrieve a page of packages when a valid page number is specified", () async {
      Page page = await client.getPageOfPackages(1);
      expect(page.next_url, "https://pub.dartlang.org/api/packages?page=2");
      expect(page.prev_url, isNull);
      expect(page.pages, 2);
      expect(page.packages.length, 2);
      expect(page.packages[0].name, "abc123");
      expect(page.packages[1].name, "cde456");
    });

    test("throws an exception for invalid page number when retrieving a page of packages", () async {
      expect(client.getPageOfPackages(5), throwsA(new isInstanceOf<HttpException>()));
    });

    test("can retrieve all packages", () async {
      List<Package> packages = await client.getAllPackages();
      expect(packages[0].name, "abc123");
      expect(packages[1].name, "cde456");
      expect(packages[2].name, "fgh678");
      expect(packages[3].name, "xyz098");
    });

    test("can retrieve a specific package", () async {
      FullPackage package = await client.getPackage("abc123");
      var now = new DateTime.now();
      expect(now.isAfter(package.created), isTrue);
    });

    test("throws an exception for invalid package name", () async {
      expect(client.getPackage("oogooaomgdakmlkd"), throwsA(new isInstanceOf<HttpException>()));
    });

    test("handles response with control characters", () async {
      Page page = await client.getPageOfPackages(42);
      expect(page.packages[0].name, "spa_router");
      expect(page.packages[0].latest.pubspec.author, "Kornel Maczyński <kornel661@gmail.com>");
    });
  });
}