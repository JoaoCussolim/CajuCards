import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  final String _baseUrl = 'https://cajucards-api.onrender.com/api';

  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = false}) {
    final headers = requireAuth ? _getHeaders() : {'Content-Type': 'application/json'};
    return _httpClient.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) {
    return _httpClient.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(), // POSTs geralmente precisam de autenticação
      body: json.encode(body),
    );
  }

  // Adicione put, delete, etc. conforme necessário
}