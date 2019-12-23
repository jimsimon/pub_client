// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) {
  return Page(
      url: json['url'] as String,
      nextUrl: json['next_url'] as String,
      packages: (json['packages'] as List)
          ?.map((e) =>
              e == null ? null : Package.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
      'url': instance.url,
      'next_url': instance.nextUrl,
      'packages': instance.packages
    };

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
      'name': instance.name,
    };

FullPackage _$FullPackageFromJson(Map<String, dynamic> json) {
  semver.Version latestSemanticVersion;
  try {
    latestSemanticVersion = semver.Version.parse(json['latest']);
  } on Exception {
    latestSemanticVersion = null;
  }
  return FullPackage(
    publisher: Publisher.fromJson(json['publisher']),
    author: json['author'],
    uploaders: _convertUploaders(json['uploaders']),
    name: json['name'],
    url: json['url'],
    repositoryUrl: json['repositoryUrl'],
    latestSemanticVersion: latestSemanticVersion,
    apiReferenceUrl: json['apiReferenceUrl'],
    platformCompatibilityTags:
        (json['compatibilityTags'] as List).cast<String>(),
    dateCreated: DateTime.fromMillisecondsSinceEpoch(json['dateCreated']),
    dateModified: DateTime.fromMillisecondsSinceEpoch(json['dateModified']),
    description: json['description'],
    homepageUrl: json['homepageUrl'],
    issuesUrl: json['issuesUrl'],
    versions: [
      for (final version in json['versions'])
        Version.fromJson((version as Map).cast<String, dynamic>())
    ],
    score: json['score'],
    packageTabs: (json['packageTabs'] as Map)?.map(
      (key, packageJson) => MapEntry(
        key,
        PackageTab.fromJson((packageJson as Map).cast<String, dynamic>()),
      ),
    ),
    likesCount: json['likesCount'],
  );
}

List<String> _convertUploaders(List json) {
  if (json == null) {
    return null;
  }
  return json.cast<String>().map((uploader) => uploader.trim()).toList();
}

Map<String, dynamic> _$FullPackageToJson(FullPackage instance) {
  final versions =
      instance?.versions?.map((version) => version.toJson())?.toList();
  return <String, dynamic>{
    'name': instance.name,
    'url': instance.url,
    'author': instance.author,
    'publisher': instance.publisher?.toJson(),
    'uploaders': instance.uploaders,
    'versions': versions,
    'latest': instance.latestSemanticVersion?.toString(),
    'score': instance.score,
    'description': instance.description,
    'type': 'fullPackage',
    'dateCreated': instance.dateCreated?.millisecondsSinceEpoch,
    'dateModified': instance.dateModified?.millisecondsSinceEpoch,
    'compatibilityTags': instance.platformCompatibilityTags,
    'packageTabs':
        instance.packageTabs?.map((key, tab) => MapEntry(key, tab.toJson())),
    'repositoryUrl': instance.repositoryUrl,
    'homepageUrl': instance.homepageUrl,
    'apiReferenceUrl': instance.apiReferenceUrl,
    'issuesUrl': instance.issuesUrl,
    'likesCount': instance.likesCount,
  };
}

Pubspec _$PubspecFromJson(Map<String, dynamic> json) {
  return Pubspec(
      environment: json['environment'] == null
          ? null
          : Environment.fromJson(json['environment'] as Map<String, dynamic>),
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      authors: (json['authors'] as List)?.map((e) => e as String)?.toList(),
      dev_dependencies: json['dev_dependencies'] == null
          ? null
          : Dependencies.fromJson(
              json['dev_dependencies'] as Map<String, dynamic>),
      dependencies: json['dependencies'] == null
          ? null
          : Dependencies.fromJson(json['dependencies'] as Map<String, dynamic>),
      homepage: json['homepage'] as String,
      name: json['name'] as String);
}

Map<String, dynamic> _$PubspecToJson(Pubspec instance) => <String, dynamic>{
      'environment': instance.environment,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'authors': instance.authors,
      'dev_dependencies': instance.dev_dependencies,
      'dependencies': instance.dependencies,
      'homepage': instance.homepage,
      'name': instance.name
    };

Environment _$EnvironmentFromJson(Map<String, dynamic> json) {
  return Environment(sdk: json['sdk'] as String);
}

Map<String, dynamic> _$EnvironmentToJson(Environment instance) =>
    <String, dynamic>{'sdk': instance.sdk};

Dependencies _$DependenciesFromJson(Map<String, dynamic> json) {
  return Dependencies()
    ..sdkDependencies = (json['sdkDependencies'] as Map<String, dynamic>)?.map((k, e) => MapEntry(
        k,
        e == null ? null : SdkDependency.fromJson(e as Map<String, dynamic>)))
    ..complexDependencies = (json['complexDependencies'] as Map<String, dynamic>)
        ?.map((k, e) => MapEntry(
            k,
            e == null
                ? null
                : ComplexDependency.fromJson(e as Map<String, dynamic>)))
    ..gitDependencies = (json['gitDependencies'] as Map<String, dynamic>)?.map((k, e) => MapEntry(
        k,
        e == null ? null : GitDependency.fromJson(e as Map<String, dynamic>)))
    ..simpleDependencies = (json['simpleDependencies'] as Map<String, dynamic>)
        ?.map((k, e) => MapEntry(k, e as String));
}

Map<String, dynamic> _$DependenciesToJson(Dependencies instance) =>
    <String, dynamic>{
      'sdkDependencies': instance.sdkDependencies,
      'complexDependencies': instance.complexDependencies,
      'gitDependencies': instance.gitDependencies,
      'simpleDependencies': instance.simpleDependencies
    };

SdkDependency _$SdkDependencyFromJson(Map<String, dynamic> json) {
  return SdkDependency(
      sdk: json['sdk'] as String, version: json['version'] as String);
}

Map<String, dynamic> _$SdkDependencyToJson(SdkDependency instance) =>
    <String, dynamic>{'sdk': instance.sdk, 'version': instance.version};

GitDependency _$GitDependencyFromJson(Map<String, dynamic> json) {
  return GitDependency(
      url: json['url'] as String,
      ref: json['ref'] as String,
      path: json['path'] as String);
}

Map<String, dynamic> _$GitDependencyToJson(GitDependency instance) =>
    <String, dynamic>{
      'url': instance.url,
      'ref': instance.ref,
      'path': instance.path
    };

ComplexDependency _$ComplexDependencyFromJson(Map<String, dynamic> json) {
  return ComplexDependency(
      hosted: json['hosted'] == null
          ? null
          : Hosted.fromJson(json['hosted'] as Map<String, dynamic>),
      version: json['version'] as String);
}

Map<String, dynamic> _$ComplexDependencyToJson(ComplexDependency instance) =>
    <String, dynamic>{'hosted': instance.hosted, 'version': instance.version};

Hosted _$HostedFromJson(Map<String, dynamic> json) {
  return Hosted(name: json['name'] as String, url: json['url'] as String);
}

Map<String, dynamic> _$HostedToJson(Hosted instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};
