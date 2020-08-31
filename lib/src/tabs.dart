part of 'models.dart';

abstract class PackageTab {
  /// The title of the tab
  final String title;

  /// The body of the tab as HTML.
  final String content;

  PackageTab({@required this.title, @required this.content});

  static String capitalizeFirstLetter(String s) =>
      (s?.isNotEmpty ?? false) ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  factory PackageTab.fromElement({
    @required String title,
    @required Element element,
  }) {
    String content = element.innerHtml;
    return getPackageTab(title: title, content: content);
  }

  static PackageTab getPackageTab({
    @required String title,
    @required String content,
  }) {
    switch (title) {
      case TabTitle.readme:
      case "Readme":
        {
          return ReadMePackageTab(
            content: content,
          );
        }
      case TabTitle.changelog:
      case "Changelog":
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
      case 'Versions':
        {
          return VersionsPackageTab(
            content: content,
          );
        }
      case TabTitle.scores:
      case "Scores":
        {
          return ScoresPackageTab(
            content: content,
          );
        }
      default:
        assert(
            false, 'Unaccounted for package tab: $title'); // throw in dev mode
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

class ScoresPackageTab extends PackageTab {
  ScoresPackageTab({@required String content})
      : super(title: "Scores", content: content) {
    final document = parse(content);
    final scores = _extractScores(document);
    popularity = scores['popularity'];
    overall = scores['pub points'];
    likes = scores['likes'];
    final dependencyTable = _extractDependencyTable(document);
    dependencies = _getDirectDependencies(dependencyTable);
  }

  ///  Describes how popular the package is relative to other packages
  int popularity;

  /// Weighted score of the above.
  int overall;

  int likes;

  List<BasicDependency> dependencies;

  Map<String, int> _extractScores(Document element) {
    final scoresParentDiv = element.querySelector('div.score-key-figures');
    final scoreElements = scoresParentDiv.querySelectorAll('.score-key-figure');
    final scores = <String, int>{
      for (final element in scoreElements)
        element.querySelector('.score-key-figure-label').text:
            int.tryParse(element.querySelector('.score-key-figure-value').text)
    };

    return scores;
  }

  List<BasicDependency> _getDirectDependencies(Element dependencyTable) {
    bool isHeaderRow(Element tableRow) {
      const String tableHeaderTag = 'th';
      if (tableRow.children
          .any((childNode) => childNode.localName == tableHeaderTag)) {
        return true;
      }
      return false;
    }

    List<BasicDependency> dependencies = [];
    var dependencyElements = dependencyTable.querySelectorAll('tr');
    // removing the main table header.
    dependencyElements
        .removeWhere((element) => element.querySelectorAll('th').length == 4);
    for (final row in dependencyElements) {
      if (!isHeaderRow(row)) {
        dependencies.add(_extractDependency(row));
      }
    }
    return dependencies;
  }

  Element _extractDependencyTable(Document document) =>
      document.querySelector('.dependency-table');

  BasicDependency _extractDependency(Element row) {
    var versionString = row.children[2].text;
    var version;
    if (versionString.isNotEmpty) {
      version = semver.Version.parse(versionString);
    }
    var versionConstraintText = row.children[1].text;
    var versionConstraint;
    if (versionConstraintText.isNotEmpty) {
      versionConstraint = semver.VersionConstraint.parse(versionConstraintText);
    }

    return BasicDependency(
      name: row.children[0].text,
      constraint: versionConstraint,
      resolved: version,
    );
  }
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
  static const String scores = "-scores-tab-";
}
