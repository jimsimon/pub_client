part of 'models.dart';

abstract class PackageTab {
  /// The title of the tab
  final String title;

  /// The body of the tab as HTML.
  final String content;

  PackageTab({@required this.title, @required this.content});

  static String capitalizeFirstLetter(String s) =>
      (s?.isNotEmpty ?? false) ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  factory PackageTab.fromElement(Element element) {
    String title = element.attributes['data-name'];
    String content = element.innerHtml;
    return getPackageTab(title: title, content: content);
  }

  static PackageTab getPackageTab({
    @required String title,
    @required String content,
  }) {
    switch (title) {
      case TabTitle.readme:
      case "README.md":
        {
          return ReadMePackageTab(
            content: content,
          );
        }
      case TabTitle.changelog:
      case "CHANGELOG.md":
        {
          return ChangelogPackageTab(
            content: content,
          );
        }
      case TabTitle.example:
      case "Example":
        {
          return ExamplePackageTab(
            content: content,
          );
        }
      case TabTitle.installing:
      case "Installing":
        {
          return InstallingPackageTab(
            content: content,
          );
        }
      case TabTitle.versions:
        {
          return VersionsPackageTab(
            content: content,
          );
        }
      case TabTitle.analysis:
      case "Analysis":
        {
          return AnalysisPackageTab(
            content: content,
          );
        }
      default:
        title = RegExp(r'-(.*)-tab-').firstMatch(title).group(1);
        return GenericPackageTab(
          title: capitalizeFirstLetter(title),
          content: content,
        );
    }
  }

  Map<String, dynamic> toJson() => {
        "title": this.title,
        "content": this.content,
      };

  factory PackageTab.fromJson(Map<String, dynamic> json) {
    return getPackageTab(
      title: json["title"],
      content: json["content"],
    );
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
