import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

import 'endpoints.dart';
import 'models.dart';

class PubHtmlParsingClient {
  Client client = Client();

  PubHtmlParsingClient() {
    Endpoint.responseType = ResponseType.html;
  }

  Future<FullPackage> get(String packageName) async {
    String url = "${Endpoint.packages}/$packageName";
    Response response = await client.get(url);
    return parse(response.body);
  }

  FullPackage parse(
    String body,
  ) {
    Document document = parser.parse(body);

    var script =
        json.decode(document.querySelector('body > main > script').text);
    String name = script['name'];
    String url = script['url'];
    String description = script['description'];
    semver.Version latestVersion = semver.Version.parse(script['version']);

    Element aboutSideBar =
        document.querySelector("body > main > div.package-container > aside");
    List<String> authors = aboutSideBar
        .querySelectorAll("span.author")
        .map((element) => element.text)
        .toList();

    String author = authors.removeAt(0);
    List<String> uploaders = authors;
    int score = int.tryParse(document
        .getElementsByClassName('score-box')
        .first
        .querySelector('span')
        .text);
    DateTime dateCreated = DateTime.parse(script['dateCreated']);
    DateTime dateModified = DateTime.parse(script['dateModified']);
    List<String> compatibilityTags = document
        .getElementsByClassName('tags')
        .first
        .text
        .trim()
        .split('\n')
        .map((string) => string.trim())
        .toList();
    List<Element> versionTable = document
        .getElementsByClassName("version-table")
        .first
        .getElementsByTagName('tr');
    versionTable.removeAt(0); // removing the header row.

    List<Version> versionList = versionTable.map((element) {
      List<String> stringList = element.text
          .trim() // remove new lines
          .split('\n')
          .map((text) => text.trim()) // remove new lines and blank spaces
          .toList();
      String url = element.getElementsByTagName('a').first.attributes['href'];
      return Version(
          version: semver.Version.parse(stringList.removeAt(0)),
          uploadedDate: stringList.removeLast(),
          url: url);
    }).toList();

    List<Tab> tabs = document
        .getElementsByClassName('main tabs-content')
        .first
        .getElementsByClassName('content js-content')
        .map((element) => Tab.fromElement(element))
        .toList();
    //TODO: Add all versions

    return FullPackage(
        name: name,
        url: url,
        description: description,
        dateCreated: dateCreated,
        dateModified: dateModified,
        author: author,
        uploaders: uploaders,
        latestVersion: latestVersion,
        versions: versionList,
        score: score,
        compatibilityTags: compatibilityTags,
        tabs: tabs);
  }
}
