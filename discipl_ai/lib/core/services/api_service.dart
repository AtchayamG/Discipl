import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Central API service.
/// When [ApiConstants.baseUrl] == 'MOCK', data is loaded from assets/data/mock_data.json.
/// To use your real backend: set baseUrl = 'https://api.discipl.ai/v1' in app_constants.dart.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Map<String, dynamic>? _mockCache;

  bool get _isMock => ApiConstants.baseUrl == 'MOCK';

  /// Load the entire mock JSON once and cache it.
  Future<Map<String, dynamic>> _loadMock() async {
    if (_mockCache != null) return _mockCache!;
    final raw = await rootBundle.loadString('assets/data/mock_data.json');
    _mockCache = json.decode(raw) as Map<String, dynamic>;
    return _mockCache!;
  }

  /// GET request \u2014 returns parsed JSON map.
  Future<Map<String, dynamic>> get(String endpoint) async {
    if (_isMock) {
      final data = await _loadMock();
      // Map endpoints to mock data keys
      final key = _endpointToKey(endpoint);
      if (key != null && data.containsKey(key)) {
        return {'data': data[key], 'success': true};
      }
      return {'data': data, 'success': true}; // return all mock data
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await http
        .get(uri, headers: _headers)
        .timeout(ApiConstants.receiveTimeout);
    return _handleResponse(response);
  }

  /// POST request \u2014 sends [body] as JSON, returns parsed response.
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    if (_isMock) {
      // Simulate a successful post in mock mode
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Mock: saved successfully'};
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await http
        .post(uri, headers: _headers, body: json.encode(body))
        .timeout(ApiConstants.receiveTimeout);
    return _handleResponse(response);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await http
        .put(uri, headers: _headers, body: json.encode(body))
        .timeout(ApiConstants.receiveTimeout);
    return _handleResponse(response);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Add auth header here when ready:
        // 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'API Error: ${response.statusCode}',
    );
  }

  String? _endpointToKey(String endpoint) {
    const map = {
      '/dashboard': 'dashboard',
      '/habits': 'habits',
      '/workouts': 'workouts',
      '/progress-photos': 'progressPhotos',
      '/community/feed': 'communityFeed',
      '/challenges': 'challenges',
      '/leaderboard': 'leaderboard',
      '/ai/insights': 'aiInsights',
      '/analytics': 'analytics',
      '/user/profile': 'user',
    };
    return map[endpoint];
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}