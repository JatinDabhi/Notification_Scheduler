import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://notification-scheduler-l4b0.onrender.com/api';

  // Localtunnel requires this header to bypass the warning screen and return JSON directly
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Bypass-Tunnel-Reminder': 'true'
  };

  // Titles APIs
  static Future<Map<String, dynamic>> getTitles(
    String appId, {
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    String url = '$baseUrl/titles?appId=$appId&page=$page&limit=$limit';
    if (status != null) url += '&status=$status';
    final response = await http.get(Uri.parse(url), headers: defaultHeaders);
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createTitle(
    String appId,
    String title,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/titles'),
      headers: defaultHeaders,
      body: jsonEncode({
        'appId': appId,
        'title': title,
        'description': description,
      }),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createMultipleTitles(
    String appId,
    List<Map<String, String>> titles,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/titles'),
      headers: defaultHeaders,
      body: jsonEncode({'appId': appId, 'titles': titles}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> updateTitle(
    String appId,
    String id,
    String title,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/titles/$id?appId=$appId'),
      headers: defaultHeaders,
      body: jsonEncode({'title': title, 'description': description}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> triggerTitle(
    String appId,
    String id,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/titles/$id/trigger?appId=$appId'),
      headers: defaultHeaders,
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> triggerInstant(
    String appId,
    String title,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/titles/trigger-instant'),
      headers: defaultHeaders,
      body: jsonEncode({
        'appId': appId,
        'title': title,
        'description': description,
      }),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> deleteTitle(
    String appId,
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/titles/$id?appId=$appId'),
      headers: defaultHeaders,
    );
    return _processResponse(response);
  }

  // Settings APIs
  static Future<Map<String, dynamic>> getSettings(String appId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/settings?appId=$appId'),
      headers: defaultHeaders,
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> updateSettings(
    String appId,
    List<String> times,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings'),
      headers: defaultHeaders,
      body: jsonEncode({'appId': appId, 'notificationTimes': times}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> getLogs(String appId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/logs?appId=$appId'),
      headers: defaultHeaders,
    );
    return _processResponse(response);
  }

  // App Registration
  static Future<Map<String, dynamic>> getAllApps() async {
    final response = await http.get(
      Uri.parse('$baseUrl/apps'),
      headers: defaultHeaders,
    );
    return _processResponse(response);
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
