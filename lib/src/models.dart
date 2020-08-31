import 'dart:collection';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pub_client/src/endpoints.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

part 'models.g.dart';

part 'tabs.dart';

class Page extends ListBase<Package> {
  final String url;
  final int pageNumber;
  final String nextUrl;
  final List<Package> packages;
  final String previousUrl;

  Page({
    @required this.url,
    @required this.packages,
    this.pageNumber,
    this.nextUrl,
    this.previousUrl,
  });

  factory Page.fromJson(Map<dynamic, dynamic> json) => _$PageFromJson(json);

  factory Page.fromHtml(String body, {@required String url}) {
    Document document = parser.parse(body);
    final nextElement = document.querySelector("a[rel='next']");
    String relativeNextUrl =
        nextElement != null ? nextElement.attributes['href'] : null;
    final nextUrl =
        relativeNextUrl != null ? "https://pub.dev$relativeNextUrl" : null;
    final previousElement = document.querySelector("a[rel='prev']");
    String relativePreviousUrl =
        previousElement != null ? previousElement.attributes['href'] : null;
    final previousUrl = relativePreviousUrl != null
        ? "https://pub.dev$relativePreviousUrl"
        : null;
    final pageNumber = document.querySelector('li.-active')?.text;
    return Page(
        url: url,
        pageNumber: pageNumber != null ? int.tryParse(pageNumber) : null,
        nextUrl: nextUrl,
        previousUrl: previousUrl,
        packages: document
            .getElementsByClassName('list-item')
            ?.map((element) =>
                element == null ? null : Package.fromElement(element))
            ?.toList());
  }

  Map<String, dynamic> toJson() => _$PageToJson(this);

  /// Returns the next [Page] in the search if applicable.
  /// Returns null otherwise.
  Future<Page> get nextPage async {
    if (nextUrl == null) return null;

    Response response = await get(nextUrl);
    return Page.fromHtml(response.body, url: url);
  }

  /// Returns the previous [Page] in the search if applicable.
  /// Returns null otherwise.
  Future<Page> get previousPage async {
    if (previousUrl == null) return null;
    Response response = await get(previousUrl);
    return Page.fromHtml(response.body, url: url);
  }

  @override
  get iterator => packages.iterator;

  @override
  int get length => packages.length;

  @override
  void operator []=(int index, value) => packages[index] = value;

  @override
  operator [](int index) => packages[index];

  @override
  void set length(int newLength) => packages.length = newLength;
}

final DateFormat shortDateFormat = DateFormat.yMMMd();

class Package {
  final String name;
  final List<String> uploaders;
  final String description;
  final Publisher publisher;

  /// The packages overall ranking. Currently only available with the HTMLParsingClient
  final int score;
  DateTime _created; // unimplemented
  final String dateUpdated;
  final Version latest;
  final String versionUrl;
  final String packageUrl;

  bool get isNew {
    if (dateUpdated == null) {
      return false;
    }

    var dateUpdatedAsDateTime;

    try {
      dateUpdatedAsDateTime = DateTime.parse(dateUpdated);
    } on FormatException {
      dateUpdatedAsDateTime = DateFormat('MMM d, yyyy').parseLoose(dateUpdated);
    }
    return dateUpdatedAsDateTime.difference(DateTime.now()) >
        Duration(days: 30);
  }

  /// Flutter / Web / Other
  List<String> platformCompatibilityTags;

  Package({
    @required this.name,
    this.description,
    this.uploaders,
    this.publisher,
    this.score,
    this.latest,
    this.platformCompatibilityTags,
    this.dateUpdated,
    this.packageUrl,
    this.versionUrl,
  });

  factory Package.fromJson(Map<dynamic, dynamic> json) {
    Map latest = json['latest'];

    return Package(
      name: json['name'],
      description: json['description'],
      uploaders: (json['uploaders'] as List)?.cast<String>(),
      publisher: Publisher.fromJson(json['publisher']),
      score: json['score'],
      latest: Version.fromJson(latest),
      platformCompatibilityTags:
          (json['platformCompatibilityTags'] as List)?.cast<String>(),
      dateUpdated: json['dateUpdated'],
      packageUrl: json['packageUrl'],
      versionUrl: json['versionUrl'],
    );
  }

  DateTime get dateCreated {
    throw UnimplementedError();
  }

  set dateCreated(DateTime created) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "uploaders": this.uploaders,
      "publisher": publisher?.toJson(),
      "description": this.description,
      "score": this.score,
//      "_created": this._created?.toIso8601String(),
      "dateUpdated": this.dateUpdated,
      "latest": this.latest?.toJson(),
      "versionUrl": this.versionUrl,
      "packageUrl": this.packageUrl,
      "platformCompatibilityTags": this.platformCompatibilityTags,
    }..removeWhere((key, value) => value == null || value == "null");
  }

  bool isNewPackage() =>
      dateCreated.difference(DateTime.now()).abs().inDays <= 30;

  // Check if a user is an uploader for a package.
  bool hasUploader(String uploaderId) =>
      uploaderId != null && uploaders.contains(uploaderId);

  int get uploaderCount => uploaders.length;

  factory Package.fromElement(Element element) {
    var name = element.querySelector('.title').text.trim();
    String relativePackageUrl =
        element.querySelector('.title > a').attributes['href'];

    String packageUrl = "";
    if (!relativePackageUrl.startsWith('http')) {
      packageUrl = Endpoint.baseUrl;
    }
    final publisherElement = _extractPublisherElement(element);
    final Publisher publisher = Publisher.fromElement(publisherElement);
    packageUrl += relativePackageUrl;
    var score = int.tryParse(element.querySelector('.number')?.text ?? "");
    List<String> packageTags = element
        .getElementsByClassName('package-tag')
        .map((element) => element.text)
        .toList();
    String dateUpdated =
        element.querySelector('.metadata > span:not(.package-tag)')?.text;
    String description = element.querySelector('.description')?.text;
    return Package(
      name: name,
      packageUrl: packageUrl,
      publisher: publisher,
      latest: Version.fromElement(element),
      description: description,
      score: score,
      platformCompatibilityTags: packageTags,
      dateUpdated: dateUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Package &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          score == other.score &&
          _created == other._created &&
          dateUpdated == other.dateUpdated &&
          latest == other.latest &&
          versionUrl == other.versionUrl &&
          packageUrl == other.packageUrl &&
          isNew == other.isNew;

  @override
  int get hashCode =>
      name.hashCode ^
      description.hashCode ^
      score.hashCode ^
      _created.hashCode ^
      dateUpdated.hashCode ^
      latest.hashCode ^
      versionUrl.hashCode ^
      packageUrl.hashCode ^
      isNew.hashCode;

  Future<FullPackage> toFullPackage() => FullPackage.fromPackage(this);

  @visibleForTesting
  bool get hasNullValues => nullValues.isNotEmpty;

  @visibleForTesting
  Iterable<dynamic> get nullValues => [
        if (name == null) "name",
        if (description == null) "description",
        if (uploaders == null) "uploaders",
        if (score == null) "score",
        if (latest == null) "latest",
        if (platformCompatibilityTags == null) "platformCompatibilityTags",
        if (dateUpdated == null) "dateUpdated",
        if (packageUrl == null) "packageUrl",
        if (versionUrl == null) "versionUrl",
      ];
}

Element _extractPublisherElement(Element element) {
  return element.querySelector('a[href*="/publishers"]');
}

@JsonSerializable()
class FullPackage {
  DateTime dateCreated;
  DateTime dateModified;

  /// The original creator of the package
  final String author;
  final List<String> uploaders;

  final Publisher publisher;
  final List<Version> versions;

  final String name;
  final String url;
  final String description;
  final int score;
  final semver.Version latestSemanticVersion;
  final Map<String, PackageTab> packageTabs;
  final String repositoryUrl;
  final String homepageUrl;
  final String apiReferenceUrl;
  final String issuesUrl;
  final int likesCount;

  /// The platforms that the Dart package is compatible with.
  /// E.G. ["Flutter", "web", "other"]
  List<String> platformCompatibilityTags;

  FullPackage({
    @required this.name,
    @required this.url,
    @required this.author,
    this.publisher,
    this.uploaders,
    this.versions,
    this.latestSemanticVersion,
    this.score,
    this.description,
    this.dateCreated,
    this.dateModified,
    this.platformCompatibilityTags,
    this.packageTabs,
    this.repositoryUrl,
    this.homepageUrl,
    this.apiReferenceUrl,
    this.issuesUrl,
    this.likesCount,
  });

  factory FullPackage.fromJson(Map<dynamic, dynamic> json) {
    if (json['type'] == 'dartLibraryPackage') {
      return DartLibraryFullPackage.fromJson(json);
    } else {
      return _$FullPackageFromJson(json);
    }
  }

  Map<String, dynamic> toJson() => _$FullPackageToJson(this);

  static Future<FullPackage> fromPackage(Package package) async {
    final url = package.packageUrl;
    final Response readmeDoc = await get(url);
    final versionsDoc = await get("$url/$_versions");
    final scoreDoc = await get("$url/$_scores");
    final changeLogDoc = await get("$url/$_changeLog");
    final installingDoc = await get("$url/$_installing");
    final exampleDoc = await get("$url/$_example");
    return FullPackage.fromHtml(
      readmeSource: readmeDoc.body,
      changelogSource: changeLogDoc.body,
      installingSource: installingDoc.body,
      exampleSource: exampleDoc.body,
      versionsSource: versionsDoc.body,
      scoresSource: scoreDoc.body,
    );
  }

  factory FullPackage.fromHtml({
    @required String readmeSource,
    @required String changelogSource,
    @required String exampleSource,
    @required String installingSource,
    @required String versionsSource,
    @required String scoresSource,
  }) {
    Document document = parser.parse(readmeSource);

    final script = json.decode(
      document
              .getElementsByTagName('script')
              .firstWhere((script) => script.text.isNotEmpty,
                  orElse: () => null)
              ?.text ??
          "{}",
    );

    String name = script[
        'name']; // TODO (@ThinkDigitalSoftware) account for cases where this fails.
    String url = script['url'];
    String description = script['description'];
    var separator = ' - ';
    description = description
        .substring(description.indexOf(separator) + separator.length);

    semver.Version latestVersion;
    if (script['version'] != null) {
      latestVersion = semver.Version.parse(script['version']);
    } else {
      latestVersion = null;
      print('Latest version is null.');
    }

    // sidebar details
    Element aboutSideBar = document.querySelector("aside");

    List<Element> links = aboutSideBar.querySelectorAll('.link');
    String homepageUrl;
    final homepageElement = links.firstWhere(
        (element) => element.text.contains('Homepage'),
        orElse: () => null);
    if (homepageElement != null) {
      homepageUrl = homepageElement.attributes['href'];
    }

    String repositoryUrl;
    final repositoryElement = links.firstWhere(
        (element) => element.text.contains('Repository'),
        orElse: () => null);
    if (repositoryElement != null) {
      repositoryUrl = repositoryElement.attributes['href'];
    }

    String apiReferenceUrl;
    final apiReferenceElement = links.firstWhere(
        (element) => element.text.contains('API reference'),
        orElse: () => null);
    if (apiReferenceElement != null) {
      apiReferenceUrl =
          Endpoint.baseUrl + apiReferenceElement.attributes['href'];
    }
    String issuesUrl;
    final issuesUrlElement = links.firstWhere(
        (element) => element.text.contains('issues'),
        orElse: () => null);
    if (issuesUrlElement != null) {
      issuesUrl = issuesUrlElement.attributes['href'];
    }

    Publisher publisher;
    final publisherElement = _extractPublisherElement(aboutSideBar);
    if (publisherElement != null) {
      publisher = Publisher.fromElement(publisherElement);
    }

    String author = _extractAuthor(aboutSideBar);
    List<String> uploaders = _extractUploaders(aboutSideBar);

    final scoreBox =
        document.querySelector('.packages-score.packages-score-health');
    final score = scoreBox != null
        ? int.tryParse(
            scoreBox.querySelector('.packages-score-value-number').text)
        : null;

    DateTime dateCreated = DateTime.parse(script['dateCreated']);
    DateTime dateModified = DateTime.parse(script['dateModified']);
    List<String> compatibilityTags = document
            .querySelector('div.-pub-tag-badge')
            ?.getElementsByTagName('span')
            ?.map((e) => e.text)
            ?.toList() ??
        [];

    List<Version> versionList = _extractVersionList(versionsSource);

    Map<String, PackageTab> tabMap = _extractTabMap([
      readmeSource,
      changelogSource,
      exampleSource,
      installingSource,
      versionsSource,
      scoresSource,
    ]);
    final int likesCount = extractLikesCount(document);

    return FullPackage(
        name: name,
        url: url,
        description: description,
        dateCreated: dateCreated,
        dateModified: dateModified,
        publisher: publisher,
        author: author,
        uploaders: uploaders,
        latestSemanticVersion: latestVersion,
        versions: versionList,
        score: score,
        platformCompatibilityTags: compatibilityTags,
        packageTabs: tabMap,
        homepageUrl: homepageUrl,
        repositoryUrl: repositoryUrl,
        apiReferenceUrl: apiReferenceUrl,
        issuesUrl: issuesUrl,
        likesCount: likesCount);
  }

  static List<Version> _extractVersionList(String versionsHtmlSource) {
    Document versionsDocument = parser.parse(versionsHtmlSource);

    Element versionTableElement =
        versionsDocument.querySelector('.version-table');
    List<Element> versionElements;
    if (versionTableElement != null) {
      versionElements = versionTableElement.getElementsByTagName('tr');

      versionElements.removeAt(0); // removing the header row.

    }
    return versionElements.map((element) {
      List<String> stringList = element.text
          .trim() // remove new lines
          .split('\n')
          .map((text) => text.trim()) // remove new lines and blank spaces
          .toList();
      final semver.Version semVersion = semver.Version.parse(stringList.first);
      final uploadedDate = stringList.last;
      final String url =
          "${Endpoint.baseUrl}${element.querySelector('a')?.attributes['href']}";
      final String archiveUrl =
          element.querySelector('.archive > a')?.attributes['href'];
      final String documentationUrl =
          "${Endpoint.baseUrl}${element.querySelector('.documentation > a')?.attributes['href']}";

      return Version(
          semanticVersion: semVersion,
          uploadedDate: uploadedDate,
          url: url,
          archiveUrl: archiveUrl,
          documentationUrl: documentationUrl);
    }).toList();
  }

  static Map<String, PackageTab> _extractTabMap(List<String> tabSources) {
    Map<String, PackageTab> tabMap = {};
    for (final source in tabSources) {
      final tabDocument = parser.parse(source);
      final tabName =
          tabDocument.querySelector('.detail-tab.-active')?.text ?? '_______';
      final content = tabDocument.querySelector('div.detail-tabs-content');
      final PackageTab packageTab =
          PackageTab.fromElement(title: tabName, element: content);
      tabMap[packageTab.runtimeType.toString()] = packageTab;
    }
    return tabMap;
  }

  bool get isNew => dateCreated.difference(DateTime.now()) > Duration(days: 30);

  Package get toPackage => Package(
        name: name,
        description: description,
        score: score,
        latest: versions.first,
        platformCompatibilityTags: platformCompatibilityTags,
        dateUpdated: dateModified.toString(),
        packageUrl: url,
      );

  static String _extractAuthor(Element aboutSideBar) {
    List<String> authors = aboutSideBar
        .querySelectorAll("span.author")
        .map((element) => element.text)
        .toList();
    if (authors.isNotEmpty) {
      return authors.first.trim();
    } else {
      return null;
    }
  }

  static List<String> _extractUploaders(Element aboutSideBar) {
    List<String> authors = aboutSideBar
        .querySelectorAll("span.author")
        .map((element) => element.text)
        .toList();
    return authors;
  }

  @visibleForTesting
  static int extractLikesCount(Document document) {
    var likesText = document.getElementById('likes-count').text;
    var count = RegExp(r'\d+').firstMatch(likesText).group(0);
    return int.parse(count);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullPackage &&
          runtimeType == other.runtimeType &&
          dateCreated.millisecondsSinceEpoch ==
              other.dateCreated.millisecondsSinceEpoch &&
          dateModified.millisecondsSinceEpoch ==
              other.dateModified.millisecondsSinceEpoch &&
          author == other.author &&
          uploaders == other.uploaders &&
          publisher == other.publisher &&
          name == other.name &&
          url == other.url &&
          description == other.description &&
          score == other.score &&
          latestSemanticVersion == other.latestSemanticVersion &&
          repositoryUrl == other.repositoryUrl &&
          homepageUrl == other.homepageUrl &&
          apiReferenceUrl == other.apiReferenceUrl &&
          issuesUrl == other.issuesUrl;

  @override
  int get hashCode =>
      dateCreated.millisecondsSinceEpoch.hashCode ^
      dateModified.millisecondsSinceEpoch.hashCode ^
      author.hashCode ^
      uploaders.hashCode ^
      publisher.hashCode ^
      name.hashCode ^
      url.hashCode ^
      description.hashCode ^
      score.hashCode ^
      latestSemanticVersion.hashCode ^
      repositoryUrl.hashCode ^
      homepageUrl.hashCode ^
      apiReferenceUrl.hashCode ^
      issuesUrl.hashCode;

  @visibleForTesting
  bool get hasNullValues {
    throw UnimplementedError();
  }
}

@JsonSerializable()
class DartLibraryFullPackage extends FullPackage {
  DartLibraryFullPackage({
    @required String name,
    @required String apiReferenceUrl,
  }) : super(
            name: name,
            apiReferenceUrl: apiReferenceUrl,
            author: 'Dart Team',
            url: apiReferenceUrl,
            likesCount: null);

  factory DartLibraryFullPackage.fromJson(Map<dynamic, dynamic> json) {
    return DartLibraryFullPackage(
      name: json['name'],
      apiReferenceUrl: json['apiReferenceUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map json = super.toJson();
    json['type'] = 'dartLibraryPackage';
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartLibraryFullPackage &&
          runtimeType == other.runtimeType &&
          super.apiReferenceUrl == other.apiReferenceUrl &&
          super.name == other.name;

  @override
  int get hashCode => super.hashCode;
}

@JsonSerializable()
class Version {
  semver.Version semanticVersion;
  final Pubspec pubspec;
  final String archiveUrl;
  final String packageUrl;
  final String documentationUrl;
  final String url;
  final String uploadedDate;

  Version({
    this.semanticVersion,
    this.pubspec,
    this.archiveUrl,
    this.packageUrl,
    this.documentationUrl,
    this.url,
    this.uploadedDate,
  });

  factory Version.fromJson(Map<dynamic, dynamic> json) {
    semver.Version version;
    if (json['version'] != null) {
      try {
        version = semver.Version.parse(json['version']);
      } catch (e) {
        version = null;
      }

      return Version(
        semanticVersion: version,
        pubspec: Pubspec.fromJson(json['pubspec']),
        archiveUrl: json['archive_url'],
        packageUrl: json['package_url'],
        documentationUrl: json['documentationUrl'],
        url: json['url'],
        uploadedDate: json['uploadedDate'],
      );
    } else
      return null;
  }

  factory Version.fromElement(Element element) {
    var metadata = element.querySelector('.metadata');
    List<Element> anchorTags = metadata.getElementsByTagName('a');
    Element versionAnchor = anchorTags.firstWhere(
        (element) => !element.attributes.containsKey('class'), orElse: () {
      if (metadata.text.trim().endsWith('•') && metadata.text.startsWith('v')) {
        return metadata;
      } else
        return null;
    });

    if (versionAnchor == null) {
      // there is no version for this package.
      return null;
    }

    var versionAnchorText =
        versionAnchor.text.replaceAll('v ', "").replaceAll('•', "").trim();
    return Version(
      semanticVersion: semver.Version.parse(versionAnchorText),
    );
  }

  Map<String, dynamic> toJson() => {
        'version': semanticVersion.toString(),
        'pubspec': pubspec?.toJson(),
        'archive_url': archiveUrl,
        'packageUrl': packageUrl,
        'documentationUrl': documentationUrl,
        'url': url,
        'uploadedDate': uploadedDate,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Version &&
          runtimeType == other.runtimeType &&
          semanticVersion == other.semanticVersion &&
          archiveUrl == other.archiveUrl &&
          packageUrl == other.packageUrl &&
          url == other.url &&
          uploadedDate == other.uploadedDate &&
          documentationUrl == other.documentationUrl;

  @override
  int get hashCode =>
      semanticVersion.hashCode ^
      archiveUrl.hashCode ^
      packageUrl.hashCode ^
      url.hashCode ^
      uploadedDate.hashCode ^
      documentationUrl.hashCode;
}

@JsonSerializable()
class Pubspec {
  Environment environment;
  String version;
  String description;
  String author;
  List<String> authors;
  Dependencies dev_dependencies;
  Dependencies dependencies;
  String homepage;
  String name;

  Pubspec(
      {this.environment,
      this.version,
      this.description,
      this.author,
      this.authors,
      this.dev_dependencies,
      this.dependencies,
      this.homepage,
      this.name});

  factory Pubspec.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) {
      return null;
    }
    return _$PubspecFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PubspecToJson(this);
}

@JsonSerializable()
class Environment {
  String sdk;

  Environment({this.sdk});

  factory Environment.fromJson(Map<dynamic, dynamic> json) =>
      _$EnvironmentFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);
}

@JsonSerializable()
class Dependencies {
  Map<String, SdkDependency> sdkDependencies = {};
  Map<String, ComplexDependency> complexDependencies = {};
  Map<String, GitDependency> gitDependencies = {};
  Map<String, String> simpleDependencies = {};

  Dependencies();

  factory Dependencies.fromJson(Map<dynamic, dynamic> json) {
    var dependencies = new Dependencies();

    json.forEach((key, value) {
      if (value is Map) {
        if (value.containsKey('sdk')) {
          dependencies.sdkDependencies[key] = new SdkDependency.fromJson(value);
        } else if (value.containsKey('git')) {
          dependencies.gitDependencies[key] = new GitDependency.fromJson(value);
        } else {
          dependencies.complexDependencies[key] =
              new ComplexDependency.fromJson(value);
        }
      } else {
        dependencies.simpleDependencies[key] = value;
      }
    });

    return dependencies;
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>();

    json.addAll(simpleDependencies);

    sdkDependencies.forEach((key, value) {
      json[key] = value.toJson();
    });

    gitDependencies.forEach((key, value) {
      json[key] = value.toJson();
    });

    complexDependencies.forEach((key, value) {
      json[key] = value.toJson();
    });

    return json;
  }
}

@JsonSerializable()
class SdkDependency {
  final String sdk;
  final String version;

  SdkDependency({this.sdk, this.version});

  factory SdkDependency.fromJson(Map<dynamic, dynamic> json) =>
      _$SdkDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$SdkDependencyToJson(this);
}

@JsonSerializable()
class GitDependency {
  final String url;
  String ref;
  String path;

  GitDependency({this.url, this.ref, this.path});

  factory GitDependency.fromJson(Map<dynamic, dynamic> json) {
    if (json['git'] is String) {
      return new GitDependency(url: json['git']);
    } else {
      return new GitDependency(
          url: json['git']['url'],
          ref: json['git']['ref'],
          path: json['git']['path']);
    }
  }

  Map<String, dynamic> toJson() {
    if (this.ref != null || this.path != null) {
      return {
        'git': {'url': this.url, 'ref': this.ref, 'path': this.path}
      };
    }

    return {'git': this.url};
  }
}

@JsonSerializable()
class ComplexDependency {
  final Hosted hosted;
  final String version;

  ComplexDependency({this.hosted, this.version});

  factory ComplexDependency.fromJson(Map<dynamic, dynamic> json) =>
      _$ComplexDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexDependencyToJson(this);
}

@JsonSerializable()
class BasicDependency {
  String name;
  semver.VersionConstraint constraint;
  semver.Version resolved;

  BasicDependency({
    @required this.name,
    @required this.constraint,
    @required this.resolved,
  });

  Map<String, String> toJson() {
    return {
      'name': this.name,
      'constraint': this.constraint.toString(),
      'resolved': this.resolved.toString(),
    };
  }

  factory BasicDependency.fromJson(Map<String, String> map) {
    return BasicDependency(
      name: map['name'],
      constraint: semver.VersionConstraint.parse(map['constraint']),
      resolved: semver.Version.parse(map['resolved']),
    );
  }

  @override
  String toString() {
    return 'BasicDependency{name: $name, constraint: $constraint, resolved: $resolved}';
  }
}

@JsonSerializable()
class Hosted {
  String name;
  String url;

  Hosted({this.name, this.url});

  factory Hosted.fromJson(Map<dynamic, dynamic> json) => _$HostedFromJson(json);

  Map<String, dynamic> toJson() => _$HostedToJson(this);
}

class Publisher {
  final String name;
  final String publisherUrl;

  Publisher({@required this.name, @required this.publisherUrl});

  /// Sample element HTML
  ///
  /// <a href="/publishers/flutter.dev"><img class="-pub-publisher-shield" height="20" width="20" title="Published by a pub.dev verified publisher" src="/static/img/verified-publisher-blue.svg?hash=vjkh82dtu3ug346d9mnd7uan3ssrqssv">
  /// flutter.dev
  /// </a>
  factory Publisher.fromElement(Element element) {
    if (element == null) {
      return null;
    }
    bool urlAttributeStartsWithPublishers =
        (element.attributes['href']?.startsWith('/publishers') ?? false);
    if (!urlAttributeStartsWithPublishers) {
      return null;
    }
    final String name = element.text;
    final String publisherUrl = "https://pub.dev${element.attributes['href']}";
    return Publisher(name: name, publisherUrl: publisherUrl);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'publisherUrl': this.publisherUrl,
    };
  }

  factory Publisher.fromJson(Map map) {
    if (map == null) {
      return null;
    }
    return new Publisher(
      name: map['name'] as String,
      publisherUrl: map['publisherUrl'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Publisher &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          publisherUrl == other.publisherUrl;

  @override
  int get hashCode => name.hashCode ^ publisherUrl.hashCode;
}

const _changeLog = 'changelog',
    _example = 'example',
    _installing = 'install',
    _versions = 'versions',
    _scores = 'score';
