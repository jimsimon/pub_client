import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

part 'models.g.dart';

class Page {
  String next_url;
  List<Package> packages;

  Page({this.next_url, this.packages});

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);
}

final DateFormat shortDateFormat = DateFormat.yMMMd();

@JsonSerializable()
class Package {
  String name;
  String url;
  List<String> uploaders;
  int score;
  DateTime created;
  DateTime updated;
  Version latestSemanticVersion;
  Version latest;

  Package({
    this.name,
    this.url,
    this.latestSemanticVersion,
    this.score,
  });

  factory Package.fromJson(Map<String, dynamic> json) =>
      _$PackageFromJson(json);

  Map<String, dynamic> toJson() => _$PackageToJson(this);

  bool isNewPackage() =>
      created
          .difference(DateTime.now())
          .abs()
          .inDays <= 30;

//  semver.Version get latestSemanticVersion => semver.Version.parse();

  String get shortUpdated {
    return shortDateFormat.format(updated);
  }

  // Check if a user is an uploader for a package.
  bool hasUploader(String uploaderId) {
    return uploaderId != null && uploaders.contains(uploaderId);
  }

  int get uploaderCount => uploaders.length;
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

  /// The platforms that the Dart package is compatible with.
  /// E.G. ["Flutter", "web", "other"]
  List<String> compatibilityTags;

  FullPackage({@required this.name,
    @required this.url,
    @required this.author,
    this.uploaders,
    this.versions,
    this.latestVersion,
    this.score,
    this.description,
    this.dateCreated,
    this.dateModified,
    this.compatibilityTags});

  factory FullPackage.fromJson(Map<String, dynamic> json) =>
      _$FullPackageFromJson(json);

  Map<String, dynamic> toJson() => _$FullPackageToJson(this);
}

@JsonSerializable()
class Version {
  Pubspec pubspec;
  String url;
  String archive_url;
  semver.Version version;
  String new_dartdoc_url;
  String package_url;
  String uploadedDate;

  Version({
    this.pubspec,
    this.url,
    this.uploadedDate,
    this.archive_url,
    this.version,
    this.new_dartdoc_url,
    this.package_url,
  });

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);

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

  Pubspec({this.environment,
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
