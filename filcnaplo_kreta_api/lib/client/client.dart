// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:filcnaplo/api/login.dart';
import 'package:filcnaplo/api/providers/user_provider.dart';
// import 'package:filcnaplo/api/nonce.dart'; // nincs nonce
import 'package:filcnaplo/api/providers/status_provider.dart';
import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/utils/jwt.dart';
import 'package:filcnaplo_kreta_api/client/api.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'dart:async';

class KretaClient {
  String? accessToken;
  String? refreshToken;
  String? idToken;
  String? userAgent;
  late http.Client client;

  late final SettingsProvider _settings;
  late final UserProvider _user;
  late final StatusProvider _status;

  bool _loginRefreshing = false;

  
  static const bool useUjKreta = true;

  KretaClient({
    this.accessToken,
    required SettingsProvider settings,
    required UserProvider user,
    required StatusProvider status,
  })  : _settings = settings,
        _user = user,
        _status = status,
        userAgent = settings.config.userAgent {
    var ioclient = HttpClient();
    ioclient.badCertificateCallback = _checkCerts;
    client = http.IOClient(ioclient);
  }

  bool _checkCerts(X509Certificate cert, String host, int port) {
    return _settings.developerMode;
  }

  Future<dynamic> getAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    bool json = true,
    bool rawResponse = false,
  }) async {
    Map<String, String> headerMap = headers != null ? Map.from(headers) : {};

    if (rawResponse) json = false;

    try {
      http.Response? res;

      for (int i = 0; i < 3; i++) {
        if (autoHeader) {
          if (!headerMap.containsKey("authorization") && accessToken != null) {
            headerMap["authorization"] = "Bearer $accessToken";
          }
          if (!headerMap.containsKey("user-agent") && userAgent != null) {
            headerMap["user-agent"] = "$userAgent";
          }
        }

        res = await client.get(Uri.parse(url), headers: headerMap);
        _status.triggerRequest(res);

        if (res.statusCode == 401) {
          await refreshLogin();
          headerMap.remove("authorization");
        } else {
          break;
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (res == null) throw "Login error";
      if (res.body == 'invalid_grant' || res.body.replaceAll(' ', '') == '') {
        throw "Auth error";
      }

      if (json) {
        return jsonDecode(res.body);
      } else if (rawResponse) {
        return res.bodyBytes;
      } else {
        return res.body;
      }
    } on http.ClientException catch (error) {
      print(
          "ERROR: KretaClient.getAPI ($url) ClientException: ${error.message}");
    } catch (error) {
      print("ERROR: KretaClient.getAPI ($url) ${error.runtimeType}: $error");
    }
  }

  Future<dynamic> postAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    bool json = true,
    Object? body,
  }) async {
    Map<String, String> headerMap = headers != null ? Map.from(headers) : {};

    try {
      http.Response? res;

      for (int i = 0; i < 3; i++) {
        if (autoHeader) {
          if (!headerMap.containsKey("authorization") && accessToken != null) {
            headerMap["authorization"] = "Bearer $accessToken";
          }
          if (!headerMap.containsKey("user-agent") && userAgent != null) {
            headerMap["user-agent"] = "$userAgent";
          }
          if (!headerMap.containsKey("content-type")) {
            headerMap["content-type"] = "application/json";
          }
          if (url.contains('kommunikacio/uzenetek')) {
            headerMap["X-Uzenet-Lokalizacio"] = "hu-HU";
          }
        }

        res = await client.post(Uri.parse(url), headers: headerMap, body: body);
        if (res.statusCode == 401) {
          await refreshLogin();
          headerMap.remove("authorization");
        } else {
          break;
        }
      }

      if (res == null) throw "Login error";

      if (json) {
        if (res.body.isEmpty) return null;
        return jsonDecode(res.body);
      } else {
        return res.body;
      }
    } on http.ClientException catch (error) {
      print(
          "ERROR: KretaClient.postAPI ($url) ClientException: ${error.message}");
    } catch (error) {
      print("ERROR: KretaClient.postAPI ($url) ${error.runtimeType}: $error");
    }
  }

  Future<dynamic> sendFilesAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    Map<String, String>? body,
  }) async {
    Map<String, String> headerMap = headers != null ? Map.from(headers) : {};

    try {
      http.StreamedResponse? res;

      for (int i = 0; i < 3; i++) {
        if (autoHeader) {
          if (!headerMap.containsKey("authorization") && accessToken != null) {
            headerMap["authorization"] = "Bearer $accessToken";
          }
          if (!headerMap.containsKey("user-agent") && userAgent != null) {
            headerMap["user-agent"] = "$userAgent";
          }
          if (!headerMap.containsKey("content-type")) {
            headerMap["content-type"] = "multipart/form-data";
          }
        }

        var request = http.MultipartRequest("POST", Uri.parse(url));
        request.fields.addAll(body ?? {});
        request.headers.addAll(headerMap);

        res = await request.send();

        if (res.statusCode == 401) {
          await refreshLogin();
          headerMap.remove("authorization");
        } else {
          break;
        }
      }

      if (res == null) throw "Login error";
      return res.statusCode;
    } on http.ClientException catch (error) {
      print(
          "ERROR: KretaClient.sendFilesAPI ($url) ClientException: ${error.message}");
    } catch (error) {
      print(
          "ERROR: KretaClient.sendFilesAPI ($url) ${error.runtimeType}: $error");
    }
  }


  static Map<String, String> _passwordBody({
    required String username,
    required String password,
    String? instituteCode,
  }) {
    return {
      'grant_type': 'password',
      'username': username,
      'password': password,
  
      'userName': username,
      if (instituteCode != null && instituteCode.isNotEmpty)
        'institute_code': instituteCode,
      'client_id': KretaAPI.clientId,
    };
  }

  static Map<String, String> _refreshBody({
    required String refreshToken,
    String? instituteCode,
  }) {
    return {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      if (instituteCode != null && instituteCode.isNotEmpty)
        'institute_code': instituteCode,
      'client_id': KretaAPI.clientId,
    };
  }

  Future<void> refreshLogin() async {
    if (_loginRefreshing) return;
    _loginRefreshing = true;

    try {
      User? loginUser = _user.user;
      if (loginUser == null) return;

      final headers = <String, String>{
        "content-type": "application/x-www-form-urlencoded",
      };

 
      if (!useUjKreta) {
        try {
          // ignore: unused_local_variable
          final nonceStr = await getAPI(KretaAPI.nonce, json: false);
         
        } catch (_) {}
      }

      if (_settings.presentationMode) {
        print("DEBUG: refreshLogin: ${loginUser.id}");
      } else {
        print("DEBUG: refreshLogin: ${loginUser.id} ${loginUser.name}");
      }

      // 1) Password grant (vagy ha van refresh_token, azt preferáld)
      Map? loginRes;

      if (refreshToken != null && refreshToken!.isNotEmpty) {
        loginRes = await postAPI(
          KretaAPI.login,
          headers: headers,
          body: _refreshBody(
            refreshToken: refreshToken!,
            instituteCode: loginUser.instituteCode,
          ),
        );
      }

      // Ha refresh nem ment / nincs token → password
      if (loginRes == null || loginRes['access_token'] == null) {
        loginRes = await postAPI(
          KretaAPI.login,
          headers: headers,
          body: _passwordBody(
            username: loginUser.username,
            password: loginUser.password,
            instituteCode: loginUser.instituteCode,
          ),
        );
      }

      if (loginRes != null) {
        if (loginRes.containsKey("access_token")) {
          accessToken = loginRes["access_token"];
        }
        if (loginRes.containsKey("refresh_token")) {
          refreshToken = loginRes["refresh_token"];
        }
        if (loginRes.containsKey("id_token")) {
          idToken = loginRes["id_token"];
        }

        loginUser.role =
            JwtUtils.getRoleFromJWT(accessToken ?? "") ?? Role.student;
      }
    } finally {
      _loginRefreshing = false;
    }
  }

  /// Első bejelentkezés (login képernyő).
  Future<bool> loginWithPassword({
    required String username,
    required String password,
    String instituteCode = 'mockschool',
  }) async {
    final headers = <String, String>{
      "content-type": "application/x-www-form-urlencoded",
    };

    final res = await postAPI(
      KretaAPI.login,
      headers: headers,
      body: _passwordBody(
        username: username,
        password: password,
        instituteCode: instituteCode,
      ),
    );

    if (res is Map && res['access_token'] != null) {
      accessToken = res['access_token'];
      refreshToken = res['refresh_token'];
      idToken = res['id_token'];
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (refreshToken == null) return;

    final headers = <String, String>{
      "content-type": "application/x-www-form-urlencoded",
    };

    try {
      await postAPI(
        KretaAPI.logout,
        headers: headers,
        body: {
          'token': refreshToken!,
          'token_type_hint': 'refresh_token',
          'client_id': KretaAPI.clientId,
        },
        json: false,
      );
    } catch (_) {
      // mockban a /connect/revocation lehet, hogy 404 – nem baj
    }

    accessToken = null;
    refreshToken = null;
    idToken = null;
  }
}