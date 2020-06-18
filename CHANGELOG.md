# v3.0.3

* Fix TypeError in Dependencies.toJson
* Update dependencies

# v3.1.3
* Add PubHtmlParsingClient
* Deprecate values no longer in use on pub.dev


# v3.1.4
* Fix error where some FullPackages were showing null scores
* Add tests for scores

# v3.1.5
* Fix error where improperly formatted pages would throw an error.
    
# v3.2.0 - 3.3.0
* Add search for PubHtmlParsingClient
    * Add filters for flutter, web and all packages in search.
    * Add sorting for:  
          1. searchRelevance - *Packages are sorted by their updated time.*
          2. overAllScore - *Packages are sorted by the overall score.*
          3. recentlyUpdated - *Packages are sorted by their updated time.*
          4. newestPackage - *Packages are sorted by their created time.*
          5. popularity - *Packages are sorted by their popularity score.*

    * Add advanced search options available on pub.dev

# v3.3.3
 BREAKING CHANGE: Version.version has been renamed to Version.semanticVersion.
 
* Fix: bad state no element error when getting packages.
* Fix: versions page no longer showing up as part of tabs.

# v3.3.8
* Add sorting and filtering to PubHtmlParsingClient.getPageOfPackages.

# v3.4.0
*  Add homepageUrl, repositoryUrl, apiReferenceUrl, issuesUrl to FullPackage

# v3.4.1
*  Fix: packageUrl showing an extra prefix on some packages

# v3.4.2
*  Feat: Add support for Dart library entries.

# v3.5.0
* Add Publisher class to support the new pub Verified Publishers.
Closes #1.
* Removes useless Tags class as these cannot be easily differentiated from normal images and were not being used anyway.

# v3.6.0
* Add scores and dependency members to AnalysisPackageTab

# v3.6.1
* Remove unnecessary whitespace in packageNames.

# v3.6.2
* Add likes count to FullPackages

# v3.6.3
* Remove initial package name from description text.

# v3.6.3+1
* Fix serialization error for `Page`s

# v3.6.4
* Added getting publisher packages using the publisher name
