import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/storage_service.dart';

/// Wrapper HTTP Client MyTeam dengan injeksi JWT Bearer Token otomatis
class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (userId != null && userId.isNotEmpty) 'x-user-id': userId,
    };
  }

  static Uri _uri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final base = AppConfig.baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$base$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  static Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _headers();
    return await http.get(_uri(endpoint, queryParams), headers: headers);
  }

  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    return await http.post(_uri(endpoint), headers: headers, body: jsonEncode(body ?? {}));
  }

  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    return await http.put(_uri(endpoint), headers: headers, body: jsonEncode(body ?? {}));
  }

  static Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    return await http.patch(_uri(endpoint), headers: headers, body: jsonEncode(body ?? {}));
  }

  static Future<http.Response> delete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _headers();
    return await http.delete(_uri(endpoint, queryParams), headers: headers);
  }
}
