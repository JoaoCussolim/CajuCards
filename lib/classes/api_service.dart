import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final String _baseUrl =
      'http://10.0.2.2:3001/api';

  String? get _accessToken {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  Map<String, String> get _headers {
    final token = _accessToken;
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getAllCards() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cards'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data']['cards'];
    } else {
      throw Exception('Falha ao carregar as cartas.');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    if (_accessToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data']['user'];
    } else {
      throw Exception('Falha ao carregar o perfil do usuário.');
    }
  }

  Future<void> addUserEmote(String emoteId) async {
    if (_accessToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/emotes'),
      headers: _headers,
      body: json.encode({'emote_id': emoteId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao adicionar o emote.');
    }
  }
}
