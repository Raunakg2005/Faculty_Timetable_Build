import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Production API endpoint
  static const String baseUrl = 'https://faculty-api.quantyxio.cloud/api';
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // If we had JWT, we'd use it here
    return {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token', 
    };
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    print('=== API POST REQUEST ===');
    print('URL: $url');
    print('Data: $data');
    
    final response = await http.post(
      Uri.parse(url),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
  static Future<List<dynamic>> searchUsers(String query, {String? excludeId}) async {
    String url = '$baseUrl/auth/search?query=$query';
    if (excludeId != null) {
      url += '&excludeId=$excludeId';
    }
    print('Searching users: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );
    print('Search response: ${response.statusCode} - ${response.body}');
    return _handleResponse(response);
  }
}
