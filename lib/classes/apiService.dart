import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ATENÇÃO: Substitua pela URL da sua API.
  // Se estiver rodando a API localmente no computador, use 'http://10.0.2.2:3001/api' para o emulador Android
  // ou 'http://localhost:3001/api' para emuladores iOS ou desktop.
  // Se a API estiver em um servidor, use a URL do servidor.
  final String _baseUrl = "http://localhost:3001/api";

  // Helper para criar os cabeçalhos (headers) da requisição
  Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Helper para tratar as respostas da API
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null; // Para respostas sem corpo, como DELETE (204 No Content)
      }
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha na requisição: ${response.statusCode} - ${response.body}');
    }
  }

  // --- Rotas de Autenticação e Usuários (/users) ---
  
  ///
  ///
  ///  Não tem na API então vou só deixar vazio aqui
  ///
  ///
  ///

  /// Busca o perfil do usuário logado.
  Future<Map<String, dynamic>> getMyProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: _getHeaders(token: token),
    );
    return _handleResponse(response);
  }

  /// Busca o perfil de um usuário pelo ID.
  Future<Map<String, dynamic>> getUserProfileById(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _getHeaders(token: token),
    );
    return _handleResponse(response);
  }

  /// Atualiza o perfil do usuário logado.
  Future<Map<String, dynamic>> updateCurrentUser(String token, {required String username}) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'username': username}),
    );
    return _handleResponse(response);
  }

  /// Busca os emotes do usuário logado.
  Future<List<dynamic>> getCurrentUserEmotes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/emotes'),
      headers: _getHeaders(token: token),
    );
    final decoded = _handleResponse(response);
    return decoded['data']['emotes'];
  }

  /// Adiciona um emote à coleção do usuário logado.
  Future<Map<String, dynamic>> addUserEmote(String emoteId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/emotes'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'emote_id': emoteId}),
    );
    return _handleResponse(response);
  }

  // --- Rotas de Cartas (/cards) ---

  /// Busca todas as cartas.
  Future<List<dynamic>> getAllCards() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cards'),
      headers: _getHeaders(),
    );
    final decoded = _handleResponse(response);
    return decoded['data']['cards'];
  }

  /// Busca uma carta específica pelo ID.
  Future<Map<String, dynamic>> getCardById(String cardId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cards/$cardId'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // --- Rotas de Histórico de Partidas (/match-history) ---

  /// Busca o histórico de partidas do usuário logado.
  Future<List<dynamic>> getUserMatchHistory(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/match-history'),
      headers: _getHeaders(token: token),
    );
    final decoded = _handleResponse(response);
    return decoded['data']['matches'];
  }

  /// Busca os detalhes de uma partida específica pelo ID.
  Future<Map<String, dynamic>> getMatchDetailsById(String matchId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/match-history/$matchId'),
      headers: _getHeaders(token: token),
    );
    return _handleResponse(response);
  }

  // --- Rotas de Emotes (/emotes) ---

  /// Busca todos os emotes.
  Future<List<dynamic>> getAllEmotes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/emotes'),
      headers: _getHeaders(),
    );
    final decoded = _handleResponse(response);
    return decoded['data']['emotes'];
  }

  /// Busca um emote específico pelo ID.
  Future<Map<String, dynamic>> getEmoteById(String emoteId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/emotes/$emoteId'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }
}