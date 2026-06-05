import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ApiClient extends GetxService {
  final String baseUrl;
  final http.Client client = http.Client();

  ApiClient({required this.baseUrl});

  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Source': 'mobile-app',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<http.Response> getData(String uri, {Map<String, String>? headers}) async {
    try {
      print('\n--- 🚀 API REQUEST [GET] ---');
      print('🔗 URL: $uri');
      final reqHeaders = _getHeaders(headers);
      print('📑 HEADERS: ${jsonEncode(reqHeaders)}');
      
      http.Response response = await client.get(
        Uri.parse(uri),
        headers: reqHeaders,
      );
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------\n');
      return response;
    } catch (e) {
      print('❌ API ERROR [GET]: $e');
      return http.Response(jsonEncode({'message': e.toString(), 'success': false}), 500);
    }
  }

  Future<http.Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      print('\n--- 🚀 API REQUEST [POST] ---');
      print('🔗 URL: $uri');
      print('📝 BODY: ${jsonEncode(body)}');
      final reqHeaders = _getHeaders(headers);
      print('📑 HEADERS: ${jsonEncode(reqHeaders)}');

      http.Response response = await client.post(
        Uri.parse(uri),
        body: jsonEncode(body),
        headers: reqHeaders,
      );
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------\n');
      return response;
    } catch (e) {
      print('❌ API ERROR [POST]: $e');
      return http.Response(jsonEncode({'message': e.toString(), 'success': false}), 500);
    }
  }

  Future<http.Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      print('\n--- 🚀 API REQUEST [PUT] ---');
      print('🔗 URL: $uri');
      print('📝 BODY: ${jsonEncode(body)}');
      final reqHeaders = _getHeaders(headers);
      print('📑 HEADERS: ${jsonEncode(reqHeaders)}');

      http.Response response = await client.put(
        Uri.parse(uri),
        body: jsonEncode(body),
        headers: reqHeaders,
      );
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------\n');
      return response;
    } catch (e) {
      print('❌ API ERROR [PUT]: $e');
      return http.Response(jsonEncode({'message': e.toString(), 'success': false}), 500);
    }
  }

  Future<http.Response> deleteData(String uri, {Map<String, String>? headers}) async {
    try {
      print('\n--- 🚀 API REQUEST [DELETE] ---');
      print('🔗 URL: $uri');
      final reqHeaders = _getHeaders(headers);
      print('📑 HEADERS: ${jsonEncode(reqHeaders)}');

      http.Response response = await client.delete(
        Uri.parse(uri),
        headers: reqHeaders,
      );
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------\n');
      return response;
    } catch (e) {
      print('❌ API ERROR [DELETE]: $e');
      return http.Response(jsonEncode({'message': e.toString(), 'success': false}), 500);
    }
  }
}
