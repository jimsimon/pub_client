import 'package:html/dom.dart';
import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/exceptions.dart';
import 'package:pub_client/src/html_parsing_client.dart';
import 'package:pub_client/src/models.dart';
import 'package:pub_semver/pub_semver.dart' as semver;
import 'package:simple_smart_scraper/simple_smart_scraper.dart';
import 'package:test/test.dart';

void main() {
  PubHtmlParsingClient client = PubHtmlParsingClient();

  group('test package scores are found successfully', () {
    test('test "aiframework" score is non-null', () async {
      FullPackage aiFrameWork = await client.get('aiframework');
      expect(aiFrameWork.score, isNotNull);
    });

    test("test 'add_to_calendar' score is non-null", () async {
      FullPackage addToCalendar = await client.get('add_to_calendar');
      expect(addToCalendar.score, isNotNull);
    });

    test("test 'aiframework' score is non-null", () async {
      FullPackage potatoHelper = await client.get("potato_helper");
      expect(potatoHelper.score, isNotNull);
    });
  });

  test("Page from HTML returns a valid Page with no unexpected null values",
      () async {
    Page page = await client.getPageOfPackages(pageNumber: 1);
    for (var package in page.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.score, isNotNull);
      expect(package.platformCompatibilityTags, isNotNull);
      expect(package.dateUpdated, isNotNull);
    }
  });
  test("test getPageOfPackages", () async {
    Page sortedPageByPopularity = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.popularity, filterBy: FilterType.web);
    Page sortedPageByScore = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.overAllScore);
    Page sortedPageByRecentlyUpdated = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.recentlyUpdated);
    Page sortedPageByCreated = await client.getPageOfPackages(
        pageNumber: 1, sortBy: SortType.newestPackage);

    expect(sortedPageByPopularity.url, contains('sort=popularity'));
    expect(sortedPageByPopularity.url, contains('sort=popularity'));
    expect(sortedPageByPopularity.packages, isNotEmpty);

    expect(sortedPageByRecentlyUpdated.url, contains('sort=updated'));
    expect(sortedPageByRecentlyUpdated.packages, isNotEmpty);

    expect(sortedPageByCreated.url, contains('sort=created'));
    expect(sortedPageByCreated.packages, isNotEmpty);

    expect(sortedPageByScore.url, contains('sort=top'));
    expect(sortedPageByScore.packages, isNotEmpty);
  });

  test("test search returns valid results with no unexpected null values",
      () async {
    Page searchResults = await client.search("bloc",
        sortBy: SortType.searchRelevance, filterBy: FilterType.web);
    for (Package package in searchResults.packages) {
      expect(package.name, isNotNull);
      expect(package.description, isNotNull);
      expect(package.latest, isNotNull);
      expect(package.platformCompatibilityTags, isNotNull);
      expect(package.packageUrl, isNotNull);
      expect(package.dateUpdated, isNotNull);
    }
  });

  test("test Page.nextPage returns a valid Page", () async {
    Page searchResults = await client.search("bloc",
        sortBy: SortType.searchRelevance, filterBy: FilterType.flutter);
    Page secondPage = await searchResults.nextPage;
    expect(secondPage, isNotNull);
  });

  group("test advanced search", () {
    test('test exact phrase', () async {
      Page searchResults = await client.search("html");

      // TODO: (ThinkDigitalSoftware) wait until we support API results before testing this
      // as some results show up only because of the search string being present
      // in API results.
    });

    test('test prefix', () async {
      Page searchResults = await client.search("html", isPrefix: true);
      for (Package package in searchResults) {
        expect(package.name, startsWith('html'));
      }
    });

    test('Request for an invalid package throws an InvalidPackageException',
        () {
      expect(
        () async => await client.get('someInvalidPackage'),
        throwsA(TypeMatcher<InvalidPackageException>()),
      );
    });
    test('package can be fetched with no errors', () async {
      expect(() async => await client.get('url_launcher'), returnsNormally);
    });
  });

  test('FullPackage toJson and fromJson return no errors', () async {
    final FullPackage urlLauncher = await client.get('url_launcher');
    final json = urlLauncher.toJson();
    final FullPackage urlLauncherFromJson = FullPackage.fromJson(json);
    expect(urlLauncher, urlLauncherFromJson);
  });

  test('FullPackage fromHtml return no errors', () async {
    final FullPackage flutterBloc = await client.get('flutter_bloc');
    expect(flutterBloc, isNotNull);
  });

  test('Package toJson and fromJson return no errors', () async {
    final FullPackage urlLauncherFull = await client.get('url_launcher');
    final Package urlLauncherPackage = urlLauncherFull.toPackage;
    final json = urlLauncherPackage.toJson();
    final Package urlLauncherPackageFromJson = Package.fromJson(json);
    expect(urlLauncherPackage, urlLauncherPackageFromJson);
  });
  test('Uploaders display properly', () async {
    final package = await client.get('nb_map');
    expect(package.uploaders, isNotNull);
  });

  test('search results returns packages with no errors', () async {
    final results = await client.search('live video');
    final nonSdkPackages =
        results.where((package) => !package.name.contains('dart:'));
    for (Package package in nonSdkPackages) {
      // filtering out these two values because they're not supposed to be provided in a page search.
      final unacceptableNullValues = package.nullValues
          .where((value) => value != 'uploaders' && value != 'versionUrl');
      expect(
        unacceptableNullValues,
        isEmpty,
        reason:
            "Package: ${package.name}\nNull values: ${unacceptableNullValues}",
      );
    }
  });

  test('something', () async {
    FullPackage deepLinkNavigation = await client.get('deep_link_navigation');
    expect(true, isTrue);
  });

  test("package with non-standard build versions parse correctly", () async {
    var version = semver.Version(3, 0, 2, build: 'dart2');
    FullPackage overReact = await client.get('over_react');
    FullPackage imagePicker = await client.get('image_picker');
    print('');
  });

  test('AnalysisTab contains individual values for each variable', () async {
    final FullPackage fxpoi = await client.get('fxpoi');
  });

  test('Unnecessary characters are not present in packageNames', () async {
    final searchResults =
        await client.getPageOfPackages(sortBy: SortType.overAllScore);
    for (final package in searchResults) {
      expect(package.name, endsWith(' ').inverse());
    }
  });

  test('extract likes', () {
    final int likesCount = FullPackage.extractLikesCount(
        Document.html('<html><span id="likes-count">30 likes</span></html>'));
    expect(likesCount, equals(30));
  });

  test('getCleanedHtml', () async {
    const html = '''<div class="packages">
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/ping_discover_network">ping_discover_network</a>
      </h3>
      
<a class="packages-scores" href="/packages/ping_discover_network/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">13</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">100</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">88</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">Library that allows to ping IP subnet and discover network devices. Could be used to find printers and other devices and services in a local network.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/ping_discover_network">0.2.0+1</a>
        
        • Published: <span>Sep 7, 2019</span>
      </span>
      <span class="packages-metadata-block">
        <img class="packages-vp-icon" src="/static/img/verified-publisher-icon.svg?hash=vj1n6rdh56f4cosspfl0t5tg5r0k2n8o" title="Published by a pub.dev verified publisher">
        <a href="/publishers/tablemi.com">tablemi.com</a>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
    <div class="packages-api">
        <div class="packages-api-label">API result:</div>
        <div>
          <a href="/documentation/ping_discover_network/latest/ping_discover_network/ping_discover_network-library.html">ping_discover_network/ping_discover_network-library.html</a>
        </div>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/dart_mc_ping">dart_mc_ping</a>
      </h3>
      
<a class="packages-scores" href="/packages/dart_mc_ping/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">1</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">90</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">53</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A Dart implementation of the Minecraft ping protocol (https://wiki.vg/Server_List_Ping)</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/dart_mc_ping">1.0.10</a>
        
        • Published: <span>May 1, 2020</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
    <div class="packages-api">
        <div class="packages-api-label">API results:</div>
        <details class="packages-api-details">
          <summary>
            <a href="/documentation/dart_mc_ping/latest/packet_ping_packet/packet_ping_packet-library.html">packet_ping_packet/packet_ping_packet-library.html</a>
          </summary>
            <div class="-rest"><a href="/documentation/dart_mc_ping/latest/dart_mc_ping/dart_mc_ping-library.html">dart_mc_ping/dart_mc_ping-library.html</a></div>
            <div class="-rest"><a href="/documentation/dart_mc_ping/latest/dart_mc_client/McClient-class.html">dart_mc_client/McClient-class.html</a></div>
        </details>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/scrapy">scrapy</a>
      </h3>
      
<a class="packages-scores" href="/packages/scrapy/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">13</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">80</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">71</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A dart port of the idiomatic python library Scrapy, which provides a fast high-level web crawling &amp; scraping framework for dart and Flutter.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/scrapy">0.0.3</a>
        
        • Published: <span>Jun 18, 2019</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/simple_smart_scraper">simple_smart_scraper</a>
      </h3>
      
<a class="packages-scores" href="/packages/simple_smart_scraper/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">3</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">90</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">46</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A simple smart data scraping library. Data scraping is a technique in which a computer program extract data from human-readable output coming from another program.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/simple_smart_scraper">1.0.21</a>
        
        • Published: <span>Jan 2, 2020</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart compiled for the web">js</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Web platform">web</span>
</div>
</div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/unofficial_jisho_api">unofficial_jisho_api</a>
      </h3>
      <div class="packages-recent">
        <img class="packages-recent-icon" src="/static/img/schedule-icon.svg?hash=vgvqrvauo25rg8g3m94nt97d0jc0mjrl" title="new package">
        Added <b>30 days ago</b>
      </div>
      
<a class="packages-scores" href="/packages/unofficial_jisho_api/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">1</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">100</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">33</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">An unofficial api for searching and scraping the japanese dictionary Jisho.org</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/unofficial_jisho_api">1.1.0</a>
        
        • Published: <span>Jun 30, 2020</span>
      </span>
      <span class="packages-metadata-block">
        <img class="packages-vp-icon" src="/static/img/verified-publisher-icon.svg?hash=vj1n6rdh56f4cosspfl0t5tg5r0k2n8o" title="Published by a pub.dev verified publisher">
        <a href="/publishers/h7x4.xyz">h7x4.xyz</a>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart compiled for the web">js</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Web platform">web</span>
</div>
</div>
    <div class="packages-api">
        <div class="packages-api-label">API result:</div>
        <div>
          <a href="/documentation/unofficial_jisho_api/latest/unofficial_jisho_api/unofficial_jisho_api-library.html">unofficial_jisho_api/unofficial_jisho_api-library.html</a>
        </div>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="https://api.dart.dev/stable/2.8.4/dart-isolate/dart-isolate-library.html">dart:isolate</a>
      </h3>
      
<a class="packages-scores" href="/packages/dart:isolate/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value">
  <span class="packages-score-value-number">--</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value">
  <span class="packages-score-value-number">--</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value">
  <span class="packages-score-value-number">--</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">Concurrent programming using _isolates_:
independent workers that are similar to threads
but don't share memory,
communicating only via messages.</p>
    <p class="packages-metadata">v 2.8.4 • Dart core library</p>
    <div></div>
    <div class="packages-api">
        <div class="packages-api-label">API result:</div>
        <div>
          <a href="https://api.dart.dev/stable/2.8.4/dart-isolate/Isolate-class.html">dart-isolate/Isolate-class.html</a>
        </div>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/flutter_ping">flutter_ping</a>
      </h3>
      
<a class="packages-scores" href="/packages/flutter_ping/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">0</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">70</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">58</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A new flutter plugin to ping from Flutter Apps.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/flutter_ping">0.0.3</a>
        
        • Published: <span>Apr 5, 2019</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
    <div class="packages-api">
        <div class="packages-api-label">API results:</div>
        <details class="packages-api-details">
          <summary>
            <a href="/documentation/flutter_ping/latest/flutter_ping/flutter_ping-library.html">flutter_ping/flutter_ping-library.html</a>
          </summary>
            <div class="-rest"><a href="/documentation/flutter_ping/latest/flutter_ping/FlutterPing-class.html">flutter_ping/FlutterPing-class.html</a></div>
        </details>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/puppeteer_page_walker">puppeteer_page_walker</a>
      </h3>
      
<a class="packages-scores" href="/packages/puppeteer_page_walker/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">0</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">80</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">19</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A wrapper library of puppeteer for humane scraping. Let's write the scraping scenario separately for each browsing URL.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/puppeteer_page_walker">0.1.0+1</a>
        
        • Published: <span>Dec 8, 2019</span>
      </span>
      <span class="packages-metadata-block">
        <img class="packages-vp-icon" src="/static/img/verified-publisher-icon.svg?hash=vj1n6rdh56f4cosspfl0t5tg5r0k2n8o" title="Published by a pub.dev verified publisher">
        <a href="/publishers/dartpkg.yusuke-iwaki.com">dartpkg.yusuke-iwaki.com</a>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/puppeteer">puppeteer</a>
      </h3>
      
<a class="packages-scores" href="/packages/puppeteer/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">32</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">100</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">85</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A high-level API to control headless Chrome over the DevTools Protocol. This is a port of Puppeteer in Dart.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/puppeteer">1.18.0</a>
        
        • Published: <span>Jul 16, 2020</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
</div>
</div>
    <div class="packages-api">
        <div class="packages-api-label">API results:</div>
        <details class="packages-api-details">
          <summary>
            <a href="/documentation/puppeteer/latest/protocol_network/ResourceType-class.html">protocol_network/ResourceType-class.html</a>
          </summary>
            <div class="-rest"><a href="/documentation/puppeteer/latest/protocol_audits/MixedContentResourceType-class.html">protocol_audits/MixedContentResourceType-class.html</a></div>
        </details>
    </div>
  </div>
  <div class="packages-item">
    <div class="packages-header">
      <h3 class="packages-title">
        <a href="/packages/web_scraper">web_scraper</a>
      </h3>
      
<a class="packages-scores" href="/packages/web_scraper/score">
  <div class="packages-score packages-score-like">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">15</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">likes</div>

  </div>
  <div class="packages-score packages-score-health">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">100</span><span class="packages-score-value-sign"></span>
</div>
<div class="packages-score-label">pub points</div>

  </div>
  <div class="packages-score packages-score-popularity">
    
<div class="packages-score-value -has-value">
  <span class="packages-score-value-number">84</span><span class="packages-score-value-sign">%</span>
</div>
<div class="packages-score-label">popularity</div>

  </div>
</a>

    </div>
    <p class="packages-description">A simple web scraper to scrape HTML tags and their attributes to cast them into Lists and Maps for dart and flutter.</p>
    <p class="packages-metadata">
      <span class="packages-metadata-block">
        v <a href="/packages/web_scraper">0.0.6</a>
        
        • Published: <span>Jun 24, 2020</span>
      </span>
    </p>
    <div><div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Dart SDK">Dart</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart running on a native platform (JIT/AOT)">native</span>
  <span class="tag-badge-sub" title="Packages compatible with Dart compiled for the web">js</span>
</div>
<div class="-pub-tag-badge">
  <span class="tag-badge-main" title="Packages compatible with Flutter SDK">Flutter</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Android platform">Android</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the iOS platform">iOS</span>
  <span class="tag-badge-sub" title="Packages compatible with Flutter on the Web platform">web</span>
</div>
</div>
  </div>
</div>''';

    final cleanedHtml = await getCleanedHtml(
        'https://pub.dev/packages?q=scraping',
        keepAttributes: ['packages-item']);
    return;
  });
}

extension NegationMatcher on Matcher {
  Matcher inverse() => isNot(this);
}
