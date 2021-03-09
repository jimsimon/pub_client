[![Build Status](https://travis-ci.org/jimsimon/pub_client.svg?branch=master)](https://travis-ci.org/jimsimon/pub_client)
[![Pub](https://img.shields.io/pub/v/pub_client.svg)]()

# pub_client
A library for interacting with the REST API for Pub (pub.dartlang.org/api).  This package currently uses json_serializable to decode the JSON responses from Pub into concrete types.

Supported API Calls
--------------------
* getPageOfPackages(pageNumber) - Retrieves a single page of packages from Pub with the most recently updated packages first.
* getAllPackages() - Retrieves all possible pages of packages.  NOTE: This method has the potential to generate a lot of network traffic.
* getPackage(packageName) - Retrieves a single package by it's name.

Example Usage
-------------
```dart
import "package:pub_client/pub_client.dart";

main() async {
    PubClient client = new PubClient();
    FullPackage package = await client.getPackage("test");
    print(package.latest.version);
}
```