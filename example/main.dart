import 'package:pub_client/pub_client.dart';

main() async {
  var client = new PubClient();
  var package = await client.getPackage("test");
  print(package.latest.version);
}