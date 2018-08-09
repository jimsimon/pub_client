import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

@JsonSerializable()
class Page {
  String next_url;
  List<Package> packages;

  Page({this.next_url, this.packages});

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
  Map<String, dynamic> toJson() => _$PageToJson(this);
}

@JsonSerializable()
class Package {
  String name;
  String url;
  String uploaders_url;
  String new_version_url;
  String version_url;
  Version latest;

  Package({this.name, this.url, this.uploaders_url, this.new_version_url,
      this.version_url, this.latest});

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);
  Map<String, dynamic> toJson() => _$PackageToJson(this);
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

  FullPackage({this.created, this.downloads, this.uploaders, this.versions,
      this.name, this.url, this.uploaders_url, this.new_version_url,
      this.version_url, this.latest});

  factory FullPackage.fromJson(Map<String, dynamic> json) => _$FullPackageFromJson(json);
  Map<String, dynamic> toJson() => _$FullPackageToJson(this);
}

@JsonSerializable()
class Version {
  Pubspec pubspec;
  String url;
  String archive_url;
  String version;
  String new_dartdoc_url;
  String package_url;

  Version({this.pubspec, this.url, this.archive_url, this.version,
      this.new_dartdoc_url, this.package_url});

  factory Version.fromJson(Map<String, dynamic> json) => _$VersionFromJson(json);
  Map<String, dynamic> toJson() => _$VersionToJson(this);
}

@JsonSerializable()
class Pubspec {
  Environment environment;
  String version;
  String description;
  String author;
  List<String> authors;
  Map<String, String> dev_dependencies;
  Map<String, String> dependencies;
  String homepage;
  String name;

  Pubspec({this.environment, this.version, this.description, this.author,
      this.authors, this.dev_dependencies, this.dependencies, this.homepage,
      this.name});

  factory Pubspec.fromJson(Map<String, dynamic> json) => _$PubspecFromJson(json);
  Map<String, dynamic> toJson() => _$PubspecToJson(this);
}

@JsonSerializable()
class Environment {
  String sdk;

  Environment({this.sdk});

  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);
}