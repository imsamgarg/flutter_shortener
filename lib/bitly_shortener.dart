import 'dart:convert';
import 'package:http/http.dart';

const String _authHeader = "authorization";
const String _contentTypeHeader = "content-type";
const String _jsonContentType = "application/json";

class _ErrorsObject {
  String? field;
  String? errorCode;
  String? message;

  _ErrorsObject(dynamic data) {
    field = data["field"];
    errorCode = data["error_code"];
    message = data["message"];
  }

  @override
  String toString() {
    String error = "";
    error = message == null ? error : "message :$message \n";
    error = field == null ? error : "$error field :$field \n";
    error = errorCode == null ? error : "$error errorCode :$errorCode \n";
    return error;
  }
}

class BitLyException implements Exception {
  String? message;
  String? description;
  String? resource;
  List<_ErrorsObject>? errors;

  BitLyException(dynamic data) {
    message = data["message"];
    description = data["description"];
    resource = data["resource"];
    if (data["errors"] != null) {
      errors = [];
      data["errors"].forEach((v) {
        errors?.add(_ErrorsObject(v));
      });
    }
  }

  @override
  String toString() {
    String error = "";
    error = message == null ? error : "message :$message \n";
    error = description == null ? error : "$error description :$description \n";
    error = resource == null ? error : "$error resource :$resource \n";
    error = errors == null ? error : "$error ${errors.toString()}";
    return error;
  }
}

class BitLinkParameters {
  String? title;
  List<String?>? tags;
  String? deepLinkAppId;
  String? deepLinkAppUriPath;
  String? deepLinkInstallUrl;
  String? deepLinkInstallType;

  BitLinkParameters(
      {this.title,
      this.deepLinkAppId,
      this.deepLinkAppUriPath,
      this.deepLinkInstallType,
      this.deepLinkInstallUrl,
      this.tags});

  String _generateBody(String link, String? groupGuid,
      [String domain = "bit.ly"]) {
    final _body = {
      "long_url": link,
      "domain": domain,
      "group_guid": groupGuid,
      "title": title,
      "tags": tags,
      "deeplinks": {
        "app_id": deepLinkAppId,
        "app_uri_path": deepLinkAppUriPath,
        "install_url": deepLinkInstallUrl,
        "install_type": deepLinkInstallUrl,
      }
    };
    return jsonEncode(_body);
  }

  @override
  String toString() => _generateBody("", "");
}

class BitLyLinkData {
  dynamic? references;
  String? link;
  String? id;
  String? longUrl;
  String? title;
  bool? archived;
  String? createdAt;
  String? createdBy;
  String? clientId;
  List<String>? customBitlinks;
  List<String>? tags;
  List<_Deeplinks>? deeplinks;

  BitLyLinkData(
      {this.link,
      this.longUrl,
      this.tags,
      this.title,
      this.id,
      this.archived,
      this.clientId,
      this.createdAt,
      this.createdBy,
      this.customBitlinks,
      this.deeplinks,
      this.references});

  BitLyLinkData.fromMap(dynamic data) {
    references = data["references"];
    link = data["link"];
    id = data["id"];
    longUrl = data["long_url"];
    title = data["title"];
    archived = data["archived"];
    createdAt = data["created_at"];
    createdBy = data["created_by"];
    clientId = data["client_id"];
    customBitlinks = data["custom_bitlinks"] != null
        ? data["custom_bitlinks"].cast<String>()
        : [];
    tags = data["tags"] != null ? data["tags"].cast<String>() : [];
    if (data["deeplinks"] != null) {
      deeplinks = [];
      data["deeplinks"].forEach((v) {
        deeplinks?.add(_Deeplinks(v));
      });
    }
  }

  String _generateBody() {
    var map = <String, dynamic>{};
    map["references"] = references;
    map["link"] = link;
    map["id"] = id;
    map["long_url"] = longUrl;
    map["title"] = title;
    map["archived"] = archived;
    map["created_at"] = createdAt;
    map["created_by"] = createdBy;
    map["client_id"] = clientId;
    map["custom_bitlinks"] = customBitlinks;
    map["tags"] = tags;
    if (deeplinks != null) {
      map["deeplinks"] = deeplinks?.map((v) => v.toJson()).toList();
    }
    return jsonEncode(map);
  }

  @override
  String toString() => _generateBody();
}

class _Deeplinks {
  String? guid;
  String? bitlink;
  String? appUriPath;
  String? installUrl;
  String? appGuid;
  String? os;
  String? installType;
  String? created;
  String? modified;
  String? brandGuid;

  _Deeplinks(dynamic data) {
    guid = data["guid"];
    bitlink = data["bitlink"];
    appUriPath = data["app_uri_path"];
    installUrl = data["install_url"];
    appGuid = data["app_guid"];
    os = data["os"];
    installType = data["install_type"];
    created = data["created"];
    modified = data["modified"];
    brandGuid = data["brand_guid"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["guid"] = guid;
    map["bitlink"] = bitlink;
    map["app_uri_path"] = appUriPath;
    map["install_url"] = installUrl;
    map["app_guid"] = appGuid;
    map["os"] = os;
    map["install_type"] = installType;
    map["created"] = created;
    map["modified"] = modified;
    map["brand_guid"] = brandGuid;
    return map;
  }

  @override
  String toString() => jsonEncode(toJson());
}

/// class to work with bit.ly links
///
/// Example to create a simple short link:--
/// ```
/// try{
///   final shortener = BitLyShortener(
///     accessToken: "YOUR_TOKEN",
///   );
///   BitLyLinkData linkData=await shortener.generateShortLink(longUrl: 'ANY_URL');
///   print(linkData.link);
/// }
/// on BitLyException catch(e){ //For handling BitLyException
///   print(e);
/// }
/// on Exception catch(e){ // For handling other Exceptions related to http package
///   print(e);
/// }
/// ```
///Check out official documentation for more info.
class BitLyShortener {
  ///Access Token
  ///Access Token is required and must not be null or empty
  final String accessToken;

  static const String _shortUri = "https://api-ssl.bitly.com/v4/shorten";
  static const String _bitlinkUri = "https://api-ssl.bitly.com/v4/bitlinks";

  BitLyShortener({
    required this.accessToken,
  });

  ///Official Documentation:- Converts a long url to a Bitlink.
  ///
  ///It will Return [BitLyLinkData] after successful operation.
  ///And throws [BitLyException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = BitLyShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   BitLyLinkData linkData=await shortener.generateShortLink(longUrl: 'ANY_URL');
  ///   print(linkData.link);
  /// }
  /// on BitLyException catch(e){ //For handling BitLyException
  ///   print(e);
  /// }
  /// on Exception catch(e){ // For handling other Exceptions related to http package
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  Future<BitLyLinkData> generateShortLink({
    ///Url which you want to generate shortLink of
    ///link must be a valid link
    required String longUrl,

    ///Your Custom Domain.
    ///
    /// By Default " bit.ly "
    String domain = "bit.ly",

    /// group_guid
    /// can be null
    String? groupGuid,
  }) async {
    final _body = jsonEncode({
      "long_url": longUrl,
      "domain": domain,
      "group_guid": groupGuid,
    });
    final response = await post(
      Uri.parse(_shortUri),
      body: _body,
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final _linkData = jsonDecode(response.body);
      return BitLyLinkData.fromMap(_linkData);
    } else {
      final _errorData = jsonDecode(response.body);
      throw BitLyException(_errorData);
    }
  }

  ///Official Documentation :- Converts a long url to a Bitlink and sets additional parameters.
  ///
  ///It will Return [BitLyLinkData] after successful operation.
  ///And throws [BitLyException] on unsuccessful operation.
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = BitLyShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   // check official documentation for info regarding BitLinks
  ///   final _parameters = BitLinkParameters(
  ///     title: "title",
  ///     deepLinkAppId: "com.bitly.app",
  ///     deepLinkAppUriPath: "/store?id=123456",
  ///     deepLinkInstallUrl: "link",
  ///     deepLinkInstallType: "promote_install",
  ///   );
  ///   BitLyLinkData linkData=await shortener.generateBitLyLink(
  ///     longUrl: 'ANY_URL',
  ///     parameters:_parameters,
  ///   );
  ///   print(linkData.link);
  /// }
  /// on BitLyException catch(e){ //For handling BitLyException
  ///   print(e);
  /// }
  /// on Exception catch(e){ // For handling other Exceptions related to http package
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  Future<BitLyLinkData> generateBitLyLink({
    required BitLinkParameters parameters,
    required String longUrl,
    String domain = "bit.ly",
    String? groupGuid,
  }) async {
    final _body = parameters._generateBody(longUrl, groupGuid, domain);

    final response = await post(
      Uri.parse(_bitlinkUri),
      body: _body,
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final _linkData = jsonDecode(response.body);
      return BitLyLinkData.fromMap(_linkData);
    } else {
      final _errorData = jsonDecode(response.body);
      throw BitLyException(_errorData);
    }
  }

  ///Official Documentation :- Updates fields in the specified link...
  ///
  ///It will Return [BitLyLinkData] after successful operation.
  ///And throws [BitLyException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = BitLyShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   final oldLinkData = BitLyLinkData(
  ///       link: "bit.ly/12323", //Must Not be Null||Empty
  ///       longUrl: "YOUR_LINK",
  ///       title: "title",
  ///       createdBy: "SamG",
  ///   );
  ///   BitLyLinkData linkData=await shortener.updateBitLyLink(linkData: oldLinkData);
  ///   print(linkData.link);
  /// }
  /// on BitLyException catch(e){ //For handling BitLyException
  ///   print(e);
  /// }
  /// on Exception catch(e){ // For handling other Exceptions related to http package
  ///   print(e);
  /// }
  /// ```
  ///Check out official documentation for more info.
  Future<BitLyLinkData> updateBitLyLink(
      {required BitLyLinkData linkData}) async {
    final _body = linkData.toString();
    final response = await patch(
      Uri.parse("$_bitlinkUri/${linkData.link}"),
      body: _body,
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final _linkData = jsonDecode(response.body);
      return BitLyLinkData.fromMap(_linkData);
    } else {
      final _errorData = jsonDecode(response.body);
      throw BitLyException(_errorData);
    }
  }

  ///Official Documentation :- Returns information for the specified link...
  ///
  ///It will Return [BitLyLinkData] after successful operation.
  ///And throws [BitLyException] on unsuccessful operation.
  ///
  /// Example:--
  /// ```
  /// try{
  ///   final shortener = BitLyShortener(
  ///     accessToken: "YOUR_TOKEN",
  ///   );
  ///   BitLyLinkData linkData=await shortener.retrieveBitLyLink(link: 'bit.ly/9999');
  ///   print(linkData.link);
  /// }
  /// on BitLyException catch(e){ //For handling BitLyException
  ///   print(e);
  /// }
  /// on Exception catch(e){ // For handling other Exceptions related to http package
  ///   print(e);
  /// }
  /// ```
  ///
  ///Check out official documentation for more info.
  Future<BitLyLinkData> retrieveBitLyLink({required String link}) async {
    final response = await get(
      Uri.parse("$_bitlinkUri/$link"),
      headers: {
        _contentTypeHeader: _jsonContentType,
        _authHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final _linkData = jsonDecode(response.body);
      return BitLyLinkData.fromMap(_linkData);
    } else {
      final _errorData = jsonDecode(response.body);
      throw BitLyException(_errorData);
    }
  }
}
