import 'package:http/http.dart';
import 'package:pub_client/pub_client.dart';
import 'package:pub_client/src/endpoints.dart';
import 'package:pub_client/src/models.dart';

class PubHtmlParsingClient {
  Client client = Client();

  PubHtmlParsingClient() {
    Endpoint.responseType = ResponseType.html;
  }

  Future<FullPackage> get(String packageName) async {
    String url = "${Endpoint.packages}/$packageName";
    Response response = await client.get(url);
    return FullPackage.fromHtml(response.body);
  }

  Future<Page> getPageOfPackages(int pageNumber) async {
    String url = "${Endpoint.packages}?page=$pageNumber";
    Response response = await client.get(url);
    if (response.statusCode >= 300) {
      throw HttpException(response.statusCode, response.body);
    }
    String body = response.body;
    return Page.fromHtml(body);
  }
}
