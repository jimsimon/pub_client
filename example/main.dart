import 'package:pub_client/pub_client.dart';

void main() async {
  var client = new PubClient();
  var package = await client.getPackage("test");
  var results = await client.getAllPackages();

  var pubClientPackage = await client.getPackage("http");
  print(pubClientPackage.toJson());
}
