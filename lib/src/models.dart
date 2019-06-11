import 'package:gcloud/db.dart' show Key;
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'package:intl/intl.dart';

part 'models.g.dart';

@JsonSerializable()
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
  String uploaders_url;
  String new_version_url;
  String version_url;
  Version latest;
  DateTime created;
  DateTime updated;
  int downloads;
  Key latestVersionKey;

  Key latestDevVersionKey;

  Package(
      {this.name,
      this.url,
      this.uploaders_url,
      this.new_version_url,
      this.version_url,
      this.latest});

  factory Package.fromJson(Map<String, dynamic> json) =>
      _$PackageFromJson(json);

  Map<String, dynamic> toJson() => _$PackageToJson(this);

  bool isNewPackage() => created.difference(DateTime.now()).abs().inDays <= 30;

  String get latestVersion => latestVersionKey.id as String;

  Version get latestSemanticVersion =>
      Version.parse(latestVersionKey.id as String);

  String get latestDevVersion => latestDevVersionKey?.id as String;

  Version get latestDevSemanticVersion =>
      latestDevVersionKey == null ? null : Version.parse(latestDevVersion);

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
  DateTime created;
  int downloads;
  List<String> uploaders;
  List<Version> versions;
  String name;
  String url;
  String uploaders_url;
  String new_version_url;
  String version_url;
  Version latest;

  FullPackage(
      {this.created,
      this.downloads,
      this.uploaders,
      this.versions,
      this.name,
      this.url,
      this.uploaders_url,
      this.new_version_url,
      this.version_url,
      this.latest});

  factory FullPackage.fromJson(Map<String, dynamic> json) =>
      _$FullPackageFromJson(json);

  Map<String, dynamic> toJson() => _$FullPackageToJson(this);
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
