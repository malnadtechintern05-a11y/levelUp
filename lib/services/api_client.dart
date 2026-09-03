import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  ApiException(this.message, {this.statusCode = 400, this.code});

  @override
  String toString() => message;
}

/// Central HTTP API Client
class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  // Callback triggered when any API responds with 401 Unauthorized
  VoidCallback? onUnauthorized;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    return _send('GET', endpoint, queryParams: queryParams);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _send('POST', endpoint, body: body);
  }

  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? body}) async {
    return _send('DELETE', endpoint, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    final baseUrl = ApiConfig.baseUrl;
    final fullPath = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';

    Uri uri = Uri.parse(fullPath);
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      final request = await _httpClient.openUrl(method, uri).timeout(const Duration(seconds: 10));

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null) {
        final jsonString = jsonEncode(body);
        request.headers.set(HttpHeaders.contentLengthHeader, utf8.encode(jsonString).length);
        request.write(jsonString);
      }

      final response = await request.close().timeout(const Duration(seconds: 10));
      final responseBody = await response.transform(utf8.decoder).join();

      Map<String, dynamic> jsonResponse = {};
      try {
        if (responseBody.isNotEmpty) {
          jsonResponse = jsonDecode(responseBody);
        }
      } catch (_) {
        throw ApiException('Invalid server response format.', statusCode: response.statusCode);
      }

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        final msg = jsonResponse['message'] ?? 'Your session has expired. Please log in again.';
        throw ApiException(msg, statusCode: 401, code: jsonResponse['code'] ?? 'UNAUTHORIZED');
      }

      if (response.statusCode >= 400) {
        final msg = jsonResponse['message'] ?? 'Request failed with status ${response.statusCode}.';
        throw ApiException(msg, statusCode: response.statusCode, code: jsonResponse['code']);
      }

      return jsonResponse;
    } on SocketException catch (e) {
      final host = uri.host;
      String hint = '';
      if (host == '127.0.0.1' || host == 'localhost') {
        hint = ' (Note: on a phone, localhost refers to the phone itself. Use your PC\'s Wi-Fi IP or tap the server icon at top right to configure).';
      }
      debugPrint('ApiClient SocketException on $fullPath: $e');
      throw ApiException('Cannot reach server at $fullPath$hint. Error: ${e.message}', statusCode: 0);
    } on TimeoutException catch (_) {
      throw ApiException('Connection timed out. Server did not respond in time.', statusCode: 408);
    } on HandshakeException catch (_) {
      throw ApiException('Secure connection could not be established.', statusCode: 0);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('ApiClient error: $e');
      throw ApiException('Unable to connect to server. Please try again.');
    }
  }
}
