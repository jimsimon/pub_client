import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pub_client/src/endpoints.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

part 'models.g.dart';
part 'tabs.dart';

class Page {
  int pageNumber;
  String next_url;
  List<Package> packages;

  Page({this.pageNumber, this.next_url, this.packages});

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);

  factory Page.fromHtml(String body) {
    Document document = parser.parse(body);
    String relativeNextUrl = document
        .getElementsByTagName('a')
        .where((element) => element.attributes['rel'] == 'next')
        .toList()
        .first
        .attributes['href'];
    return Page(
        pageNumber: int.parse(document.querySelector('li.-active').text),
        next_url: "https://pub.dev$relativeNextUrl",
        packages: document
            .getElementsByClassName('list-item')
            ?.map((element) =>
                element == null ? null : Package.fromElement(element))
            ?.toList());
  }

  Map<String, dynamic> toJson() => _$PageToJson(this);
}

final DateFormat shortDateFormat = DateFormat.yMMMd();

class Package {
  String name;
  List<String> uploaders;
  String description;

  /// The packages overall ranking. Currently only available with the HTMLParsingClient
  int score;
  DateTime _created;
  String dateUpdated;
  Version latest;
  String versionUrl;
  String packageUrl;

  /// Flutter / Web / Other
  List<String> packageTags;

  Package(
      {this.name,
      this.description,
      this.score,
      this.latest,
      this.packageTags,
      this.dateUpdated,
      this.packageUrl});

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
        name: json['name'], latest: Version.fromJson(json['latest']));
  }

  DateTime get created {
    throw UnimplementedError();
  }

  set created(DateTime created) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() => _$PackageToJson(this);

  bool isNewPackage() => created.difference(DateTime.now()).abs().inDays <= 30;

//  semver.Version get latestSemanticVersion => semver.Version.parse();

  // Check if a user is an uploader for a package.
  bool hasUploader(String uploaderId) {
    return uploaderId != null && uploaders.contains(uploaderId);
  }

  int get uploaderCount => uploaders.length;

  factory Package.fromElement(Element element) {
    var name = element.querySelector('.title').text;

    String relativePackageUrl =
        element.querySelector('.title > a').attributes['href'];
    var packageUrl = Endpoint.baseUrl + relativePackageUrl;
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
      latest: Version.fromElement(element),
      description: description,
      score: score,
      packageTags: packageTags,
      dateUpdated: dateUpdated,
    );
  }
}

@JsonSerializable()
class FullPackage {
  DateTime dateCreated;
  DateTime dateModified;

  /// The original creator of the package
  String author;
  List<String> uploaders;
  List<Version> versions;

  @Deprecated("Use dateCreated")
  DateTime created;
  String name;
  String url;
  String description;
  int score;
  semver.Version latestVersion;
  @Deprecated("use latestVersion")
  Version latest;
  List<Tab> tabs;
  List<Tag> tags;

  /// The platforms that the Dart package is compatible with.
  /// E.G. ["Flutter", "web", "other"]
  List<String> compatibilityTags;

  FullPackage(
      {@required this.name,
      @required this.url,
      @required this.author,
      this.uploaders,
      this.versions,
      this.latestVersion,
      this.score,
      this.description,
      this.dateCreated,
      this.dateModified,
      this.compatibilityTags,
      this.tabs});

  factory FullPackage.fromJson(Map<String, dynamic> json) =>
      _$FullPackageFromJson(json);

  Map<String, dynamic> toJson() => _$FullPackageToJson(this);

  factory FullPackage.fromHtml(String body) {
    Document document = parser.parse(body);

    var script = json.decode(document
        .querySelector('body > main')
        .getElementsByTagName('script')
        .first
        .text);
    String name = script['name'];
    String url = script['url'];
    String description = script['description'];
    semver.Version latestVersion = semver.Version.parse(script['version']);

    Element aboutSideBar = document.getElementsByTagName("aside").first;
    List<String> authors = aboutSideBar
        .querySelectorAll("span.author")
        .map((element) => element.text)
        .toList();

    String author = authors.removeAt(0);
    List<String> uploaders = authors;
    int score = int.tryParse(document
        .getElementsByClassName('score-box')
        .first
        .getElementsByClassName('number')
        .first
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

@JsonSerializable()
class Version {
  semver.Version version;
  Pubspec pubspec;
  String archiveUrl;
  String packageUrl;
  String url;
  String uploadedDate;

  Version({
    this.version,
    this.pubspec,
    this.archiveUrl,
    this.packageUrl,
    this.url,
    this.uploadedDate,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
        version: semver.Version.parse(json['version']),
        pubspec: Pubspec.fromJson(json['pubspec']),
        archiveUrl: json['archive_url'],
        packageUrl: json['package_url'],
        url: json['url']);
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
    var versionAnchorText =
        versionAnchor.text.replaceAll('v ', "").replaceAll('•', "").trim();
    return Version(
      version: semver.Version.parse(versionAnchorText),
    );
  }

  Map<String, dynamic> toJson() => _$VersionToJson(this);
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

  factory Pubspec.fromJson(Map<String, dynamic> json) =>
      _$PubspecFromJson(json);

  Map<String, dynamic> toJson() => _$PubspecToJson(this);
}

@JsonSerializable()
class Environment {
  String sdk;

  Environment({this.sdk});

  factory Environment.fromJson(Map<String, dynamic> json) =>
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

  factory Dependencies.fromJson(Map<String, dynamic> json) {
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

  factory SdkDependency.fromJson(Map<String, dynamic> json) =>
      _$SdkDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$SdkDependencyToJson(this);
}

@JsonSerializable()
class GitDependency {
  final String url;
  String ref;
  String path;

  GitDependency({this.url, this.ref, this.path});

  factory GitDependency.fromJson(Map<String, dynamic> json) {
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

  factory ComplexDependency.fromJson(Map<String, dynamic> json) =>
      _$ComplexDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexDependencyToJson(this);
}

@JsonSerializable()
class Hosted {
  String name;
  String url;

  Hosted({this.name, this.url});

  factory Hosted.fromJson(Map<String, dynamic> json) => _$HostedFromJson(json);

  Map<String, dynamic> toJson() => _$HostedToJson(this);
}
