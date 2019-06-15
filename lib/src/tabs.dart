part of 'models.dart';

abstract class Tab {
  final String title;
  final String content;

  Tab({@required this.title, @required this.content});

  factory Tab.fromElement(Element element) {
    String title = element.attributes['data-name'];
    switch (title) {
      case TabTitle.readme:
        {
          return ReadMeTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.changelog:
        {
          return ChangelogTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.example:
        {
          return ExampleTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.installing:
        {
          return InstallingTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.versions:
        {
          return VersionsTab(
            content: element.innerHtml,
          );
        }
      case TabTitle.analysis:
        {
          return AnalysisTab(
            content: element.innerHtml,
          );
        }
      default:
        throw UnsupportedError("Tab title received was: $title");
    }
  }
}

class ReadMeTab extends Tab {
  ReadMeTab({@required String content})
      : super(title: "README.md", content: content);
}

class ChangelogTab extends Tab {
  ChangelogTab({@required String content})
      : super(title: "CHANGELOG.md", content: content);
}

class ExampleTab extends Tab {
  ExampleTab({@required String content})
      : super(title: "Example", content: content);
}

class InstallingTab extends Tab {
  InstallingTab({@required String content})
      : super(title: "Installing", content: content);
}

class VersionsTab extends Tab {
  VersionsTab({@required String content})
      : super(title: "Versions", content: content);
}

class AnalysisTab extends Tab {
  AnalysisTab({@required String content})
      : super(title: "Analysis", content: content);
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
