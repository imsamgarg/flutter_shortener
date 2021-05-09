import 'dart:convert';
import 'package:http/http.dart';

///shorte.st link data class
class ShorteStLinkData {
  ///Request Status..
  ///value is "ok" in most cases.
  String? status;

  ///shortened url
  String? shortenedUrl;

  ShorteStLinkData({this.status, this.shortenedUrl});

  ShorteStLinkData._fromJson(dynamic json) {
    status = json["status"];
    shortenedUrl = json["shortenedUrl"];
  }

  Map<String, dynamic> _toJson() {
    var map = <String, dynamic>{};
    map["status"] = status;
    map["shortenedUrl"] = shortenedUrl;
    return map;
  }

  @override
  String toString() {
    return _toJson().toString();
  }
}

///shorte.st link shortener class.
///shorte.st only provide just one api to work with short links.
///
/// Example::-
/// ```
/// try{
///   final shortener = ShorteStShortener( accessToken:"YOUR_TOKEN");
///   final linkData = await shortener.generateShortLink("www.abc.xyz");
///   print(linkData.shortenedUrl);
/// } on Exception catch(e){//For Bad Requests
///   print(e);
/// }
/// ```
class ShorteStShortener {
  ///access token provided by shorte.st.
  ///must not be null or empty.
  final String accessToken;

  ShorteStShortener({required this.accessToken});

  static const String _url = "https://api.shorte.st/v1/data/url";

  /// Generate Short Link.
  ///
  /// Example::-
  /// ```
  /// try{
  ///   final shortener = ShorteStShortener( accessToken:"YOUR_TOKEN");
  ///   final linkData = await shortener.generateShortLink("www.abc.xyz");
  ///   print(linkData.shortenedUrl);
  /// } on Exception catch(e){//For Bad Requests
  ///   print(e);
  /// }
  /// ```
  Future<ShorteStLinkData> generateShortLink(

      ///link you want to be shortened.
      ///must be a valid link
      String link) async {
    final response = await put(
      Uri.parse(_url),
      headers: {
        "public-api-token": accessToken,
      },
      body: {'urlToShorten': link},
    );
    if (response.statusCode == 200) {
      if (response.headers["content-type"] == "application/json") {
        return ShorteStLinkData._fromJson(jsonDecode(response.body));
      }
      throw Exception(
          "Bad Request!! Your link might be invalid Or There might be a problem with your access token");
    }
    throw Exception(
        "Bad Request!! Your link might be invalid Or There might be a problem with your access token");
  }
}
