import 'dart:convert';
import 'package:http/http.dart';

const String _authHeader = "authorization";
const String _acceptHeader = "accept";
const String _contentTypeHeader = "content-type";
const String _jsonContentType = "application/json";

///[TinyUrlException]--
///thrown on each unsuccessful request to tinyurl api
class TinyUrlException {
  ///error code
  int? code;

  ///List of error messages
  List<String>? errors;

  ///[TinyUrlException]--
  ///thrown on each unsuccessful request to tinyurl api
  TinyUrlException({
    this.code,
    this.errors,
  });

  factory TinyUrlException._fromMap(Map<String, dynamic> map) {
    return TinyUrlException(
      code: map['code'],
      errors: List<String>.from(map['errors']),
    );
  }

  factory TinyUrlException._fromJson(String source) =>
      TinyUrlException._fromMap(json.decode(source));
}

///[TinyUrlLinkData] class that hold all the metadata of the link shortened.
///an instance of the class will be returned after each successful request
///to tinyurl apis containing all the data send by the api
class TinyUrlLinkData {
  ///Long Url
  final String url;

  ///Domain Name
  final String domain;

  ///Link Alias
  final String alias;

  ///Link Tags
  final List<String> tags;

  ///Short Url
  final String shortUrl;

  ///[TinyUrlLinkData] class that hold all the metadata of the link shortened.
  ///an instance of the class will be returned after each successful request
  ///to tinyurl apis containing all the data send by the api
  TinyUrlLinkData({
    required this.url,
    required this.domain,
    required this.alias,
    required this.tags,
    required this.shortUrl,
  });

  factory TinyUrlLinkData._fromMap(Map<String, dynamic> data) {
    final map = data['data'];
    return TinyUrlLinkData(
      url: map['url'],
      domain: map['domain'],
      alias: map['alias'],
      tags: List<String>.from(map['tags']),
      shortUrl: map['tiny_url'],
    );
  }

  factory TinyUrlLinkData._fromJson(String source) =>
      TinyUrlLinkData._fromMap(json.decode(source));

  @override
  String toString() {
    return 'Data(url: $url, domain: $domain, alias: $alias, tags: $tags, tiny_url: $shortUrl)';
  }
}

/// class to work with TinyUrl links
///
/// Example to create a simple short link:--
/// ```
/// try{
///   final shortener = TinyUrlShortener(
///     accessToken: "YOUR_TOKEN",
///   );
///   final linkData=await shortener.generateShortLink(longUrl: 'ANY_URL');
///   print(linkData.shortUrl);
/// }
/// on TinyUrlException catch(e){ // For handling TinyUrlException
///   print(e);
/// }
/// ```
///Check out official documentation for more info.
class TinyUrlShortener {
  ///Access Token is required and must not be null or empty
  String accessToken;

  ///The domain you would like the TinyURL to use.
  ///```
  ///default: tinyurl.com
  ///example: tiny.one
  ///Free Domains:
  ///   tinyurl.com
  ///   rtf.lol
  ///   tiny.one
  ///```
  String? domain;

  ///A short string of characters to use in the TinyURL.
  ///If omitted, one will be randomly generated.
  ///When using a branded domain,
  ///```
  ///example
  ///tags: [example ,link]
  ///
  ///max length :45
  /// ```
  List<String>? tags;

  ///Alias
  ///```
  ///maxLength: 30
  ///minLength: 5
  ///example: myexamplelink
  /// ```
  String? alias;

  static const String _createUrl = "https://api.tinyurl.com/create";
  static const String _changeUrl = "https://api.tinyurl.com/change";
  static const String _updateUrl = "https://api.tinyurl.com/update";

  /// class to work with TinyUrl links
  ///
  /// Example to create a simple short link:--
  /// ```
  /// try{
  ///   final shortener = TinyUrlShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   final linkData=await shortener.generateShortLink(longUrl: 'ANY_URL');
  ///   print(linkData.shortUrl);
  /// }
  /// on TinyUrlException catch(e){ // For handling TinyUrlException
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  TinyUrlShortener({
    required this.accessToken,
    this.alias,
    this.domain,
    this.tags,
  });

  ///Official Documentation:- Create a new TinyUrl.
  ///
  ///It will Return [TinyUrlLinkData] after successful operation.
  ///And throws [TinyUrlException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = TinyUrlShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   final linkData = await shortener.generateShortLink(longUrl: 'ANY_URL');
  ///   print(linkData.shortUrl);
  /// } on TinyUrlException catch(e){ //For handling TinyUrlException
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  Future<TinyUrlLinkData> generateShortLink({
    ///Url which you want to generate shortLink of
    ///link must be a valid link
    required String longUrl,
  }) async {
    final _data = {
      "url": longUrl,
      "domain": domain,
      "alias": alias,
      "tags": tags.toString()
    };

    final response = await post(
      Uri.parse(_createUrl),
      body: jsonEncode(_data),
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
        _acceptHeader: _jsonContentType,
      },
    );
    if (response.statusCode == 200) {
      return TinyUrlLinkData._fromJson(response.body);
    } else {
      throw TinyUrlException._fromJson(response.body);
    }
  }

  ///Official Documentation:- Create a new TinyUrl.
  ///
  ///It will Return [TinyUrlLinkData] after successful operation.
  ///And throws [TinyUrlException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = TinyUrlShortener(
  ///     accessToken: 'YOUR_TOKEN',
  ///     alias: 'ANY_ALIAS',
  ///     domain: 'ANY_DOMAIN',
  ///     tags: ['example1'],
  ///   );
  ///   final linkData = await shortener.updateLinkParameters(
  ///     newStats: true,
  ///     newDomain: 'NEW_DOMAIN',
  ///     newAlias: 'NEW_ALIAS',
  ///     newTags: ['example','tag'],
  ///   );
  ///   print(linkData.shortUrl);
  /// } on TinyUrlException catch(e){ //For handling TinyUrlException
  ///   print(e);
  /// }
  /// ```
  ///NOTE:-
  ///You must specify domain and alias in [TinyUrlShortener] Parameters
  ///
  ///Check out official documentation for more info.
  Future<TinyUrlLinkData> updateLinkParameters(
    ///The new domain you would like to switch to
    String? newDomain,

    ///The new alias you would like to switch to
    String? newAlias,

    ///Tags you would like this TinyURL to have. Overwrites the existing tags.
    List<String>? newTags,

    ///Turns on / off the collection of click analytics
    bool? newStats,
  ) async {
    final _data = {
      "domain": domain,
      "alias": alias,
      "new_domain": newDomain,
      "new_alias": newAlias,
      "new_stats": newStats,
      "new_tags": newStats.toString()
    };

    final response = await patch(
      Uri.parse(_updateUrl),
      body: jsonEncode(_data),
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
        _acceptHeader: _jsonContentType,
      },
    );
    if (response.statusCode == 200) {
      return TinyUrlLinkData._fromJson(response.body);
    } else {
      throw TinyUrlException._fromJson(response.body);
    }
  }

  ///Official Documentation:- Create a new TinyUrl.
  ///
  ///It will Return [TinyUrlLinkData] after successful operation.
  ///And throws [TinyUrlException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = TinyUrlShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   final linkData = await shortener.updateShortLink(
  ///     longUrl: 'ANY_URL',
  ///     domain: 'ANY_DOMAIN',
  ///     alias: 'ANY_ALIAS',
  ///   );
  ///   print(linkData.shortUrl);
  /// } on TinyUrlException catch(e){ //For handling TinyUrlException
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  Future<TinyUrlLinkData> updateShortLink(
    /// Source domain
    String longUrl,

    ///	Source domain
    String domain,

    /// Source alias
    String alias,
  ) async {
    final _data = {
      "domain": domain,
      "alias": alias,
      "url": longUrl,
    };

    final response = await patch(
      Uri.parse(_changeUrl),
      body: jsonEncode(_data),
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
        _acceptHeader: _jsonContentType,
      },
    );
    if (response.statusCode == 200) {
      return TinyUrlLinkData._fromJson(response.body);
    } else {
      throw TinyUrlException._fromJson(response.body);
    }
  }
}
