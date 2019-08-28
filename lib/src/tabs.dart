part of 'models.dart';

abstract class PackageTab {
  /// The title of the tab
  final String title;

  /// The body of the tab as HTML.
  final String content;

  PackageTab({@required this.title, @required this.content});

  factory PackageTab.fromElement(Element element) {
    String capitalizeFirstLetter(String s) =>
        (s?.isNotEmpty ?? false) ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
    String title = element.attributes['data-name'];
    switch (title) {
      case TabTitle.readme:
        {
          return ReadMePackageTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.changelog:
        {
          return ChangelogPackageTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.example:
        {
          return ExamplePackageTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.installing:
        {
          return InstallingPackageTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.versions:
        {
          return VersionsPackageTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.analysis:
        {
          return AnalysisPackageTab(
            content: element.innerHtml,
          );
        }
      default:
        title = RegExp(r'-(.*)-tab-').firstMatch(title).group(1);
        return GenericPackageTab(
            title: capitalizeFirstLetter(title), content: element.innerHtml);
    }
  }
}

class ReadMePackageTab extends PackageTab {
  ReadMePackageTab({@required String content})
      : super(title: "README.md", content: content);
}

class ChangelogPackageTab extends PackageTab {
  ChangelogPackageTab({@required String content})
      : super(title: "CHANGELOG.md", content: content);
}

class ExamplePackageTab extends PackageTab {
  ExamplePackageTab({@required String content})
      : super(title: "Example", content: content);
}

class InstallingPackageTab extends PackageTab {
  InstallingPackageTab({@required String content})
      : super(title: "Installing", content: content);
}

class VersionsPackageTab extends PackageTab {
  VersionsPackageTab({@required String content})
      : super(title: "Versions", content: content);
}

class AnalysisPackageTab extends PackageTab {
  AnalysisPackageTab({@required String content})
      : super(title: "Analysis", content: content);
}

class GenericPackageTab extends PackageTab {
  GenericPackageTab({@required title, @required String content})
      : super(title: title, content: content);
}

class TabTitle {
  static const String readme = "-readme-tab-";
  static const String changelog = "-changelog-tab-";
  static const String example = "-example-tab-";
  static const String installing = "-installing-tab-";
  static const String versions = "-versions-tab-";
  static const String analysis = "-analysis-tab-";
}

/// a tag commonly seen on Github, pub.dev and other code hosting sites.
class Tag {
  String url;
}
