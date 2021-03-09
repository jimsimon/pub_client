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
      case 'README.md':
      case 'Readme':
        {
          return ReadMePackageTab(
            content: content,
          );
        }
      case TabTitle.changelog:
      case 'Changelog':
      case 'CHANGELOG.md':
        {
          return ChangelogPackageTab(
            content: content,
          );
        }
      case TabTitle.example:
      case 'Example':
        {
          return ExamplePackageTab(
            content: content,
          );
        }
      case TabTitle.installing:
      case 'Installing':
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
      case 'Scores':
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
        'title': this.title,
        'content': this.content,
      };

  factory PackageTab.fromJson(Map<String, dynamic> json) {
    return getPackageTab(
      title: json['title'],
      content: json['content'],
    );
  }
}

class ReadMePackageTab extends PackageTab {
  ReadMePackageTab({@required String content})
      : super(title: 'README.md', content: content);
}

class ChangelogPackageTab extends PackageTab {
  ChangelogPackageTab({@required String content})
      : super(title: 'CHANGELOG.md', content: content);
}

class ExamplePackageTab extends PackageTab {
  ExamplePackageTab({@required String content})
      : super(title: 'Example', content: content);
}

class InstallingPackageTab extends PackageTab {
  InstallingPackageTab({@required String content})
      : super(title: 'Installing', content: content);
}

class VersionsPackageTab extends PackageTab {
  VersionsPackageTab({@required String content})
      : super(title: 'Versions', content: content);
}

class ScoresPackageTab extends PackageTab {
  ScoresPackageTab({
    @required String content,
  }) : super(title: 'Scores', content: content) {
    final document = parse(content);
    final scores = _extractScores(document);
    popularity = scores['popularity'];
    overall = scores['pub points'];
    likes = scores['likes'];
    packageReports = scores['packageReports'];
  }

  ///  Describes how popular the package is relative to other packages
  int popularity;

  /// Weighted score of the above.
  int overall;

  int likes;

  List<PackageReport> packageReports;

  Map<String, dynamic> _extractScores(Document element) {
    final scoresParentDiv = element.querySelector('div.score-key-figures');
    final scoreElements = scoresParentDiv.querySelectorAll('.score-key-figure');
    final packageReportDiv = element.querySelector('.pkg-report');
    final reports =
        packageReportDiv.querySelectorAll('.pkg-report-section')?.map((e) {
      final description = e.querySelector('.pkg-report-header-title')?.text;
      final score =
          e.querySelector('.pkg-report-header-score-granted')?.text ?? '';
      final max = e.querySelector('.pkg-report-header-score-max')?.text ?? '';
      return PackageReport(
        description: description,
        score: _Score(score: int.tryParse(score), max: int.tryParse(max)),
      );
    });
    final scores = <String, dynamic>{
      for (final element in scoreElements)
        element.querySelector('.score-key-figure-label').text:
            int.tryParse(element.querySelector('.score-key-figure-value').text),
      'packageReports': reports.toList(),
    };

    return scores;
  }
}

class GenericPackageTab extends PackageTab {
  GenericPackageTab({@required title, @required String content})
      : super(title: title, content: content);
}

class TabTitle {
  static const String readme = '-readme-tab-';
  static const String changelog = '-changelog-tab-';
  static const String example = '-example-tab-';
  static const String installing = '-installing-tab-';
  static const String versions = '-versions-tab-';
  static const String scores = '-scores-tab-';
}

class PackageReport {
  final String description;
  final _Score score;

  //<editor-fold desc="Data Methods" defaultstate="collapsed">

  const PackageReport({
    @required this.description,
    @required this.score,
  });

  @override
  String toString() {
    return 'PackageReport{description: $description, score: $score}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageReport &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          score == other.score);

  @override
  int get hashCode => description.hashCode ^ score.hashCode;

  factory PackageReport.fromJson(Map<String, dynamic> map) {
    return PackageReport(
      description: map['description'] as String,
      score: _Score.fromJson(map['score']),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': this.description,
        'score': this.score,
      };

//</editor-fold>

}

class _Score {
  final int score;
  final int max;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const _Score({
    @required this.score,
    @required this.max,
  });

  @override
  String toString() {
    return '_Score{score: $score, max: $max}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _Score &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          max == other.max);

  @override
  int get hashCode => score.hashCode ^ max.hashCode;

  factory _Score.fromJson(Map<String, dynamic> map) {
    return _Score(
      score: map['score'] as int,
      max: map['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'score': this.score,
        'total': this.max,
      };

//</editor-fold>

}
