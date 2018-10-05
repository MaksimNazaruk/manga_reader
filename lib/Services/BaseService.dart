import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:hello_world/Services/Providers/UserSessionProvider.dart';

enum RequestType { get, post }

class RequestInfo {
  RequestType type;
  String url;
  Map<String, String> headers;
  Map<String, String> body;

  RequestInfo(
      {@required this.type,
      @required this.url,
      Map<String, String> headers,
      this.body});

  factory RequestInfo.json(
      {@required RequestType type,
      @required String url,
      Map<String, String> headers,
      Map<String, String> body}) {
    var result = RequestInfo(type: type, url: url, body: body);
    var jsonHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    if (headers != null) {
      jsonHeaders.addAll(headers);
    }
    result.headers = jsonHeaders;
    return result;
  }

  factory RequestInfo.oespJson(
      {@required RequestType type,
      @required String url,
      Map<String, String> body}) {
    var result = RequestInfo.json(type: type, url: url, body: body);
    var userSession = UserSessionProvider.currentUserSession;
    if (userSession != null) {
      var oespHeaders = {
        'X-OESP-Token': userSession.oespToken,
        'X-OESP-Username': userSession.oespUsername,
      };
      if (result.headers != null) {
        oespHeaders.addAll(result.headers);
      }
      result.headers = oespHeaders;
    }
    return result;
  }
}

class BaseService {
  Future<Map<String, dynamic>> performRequest(RequestInfo requestInfo) async {
    http.Response response;
    switch (requestInfo.type) {
      case RequestType.get:
        response =
            await http.get(requestInfo.url, headers: requestInfo.headers);
        break;
      case RequestType.post:
        var body = requestInfo.body;
        var encodedBody;
        if (body != null && body.isNotEmpty) {
          encodedBody = json.encode(body);
        }
        response = await http.post(requestInfo.url,
            headers: requestInfo.headers, body: encodedBody);
    }

    var result;
    if (_isResponseValid(response)) {
      result = _decodeResponse(response);
    } else {
      print(
          "Error during request to ${requestInfo.url}: ${response.statusCode}: ${response.reasonPhrase}");
    }
    return result;
  }

  bool _isResponseValid(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body != null) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }
}
