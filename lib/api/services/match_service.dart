// lib/api/services/match_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/models/match_history_item.dart';

class MatchService {
  final ApiClient _apiClient;

  MatchService(this._apiClient);

  Future<List<MatchHistoryItem>> getMatchHistory() async {
    final http.Response response = await _apiClient.get(
      '/matches/history', // Endpoint para o histórico (autenticado)
      requireAuth: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      
      // Assumindo que a API retorna { "data": [ ...lista de partidas... ] }
      // ou { "data": { "matches": [ ...lista de partidas... ] } }
      // Ajuste a chave 'data' ou 'matches' conforme a sua API
      final List<dynamic> matchesList = decoded['data'] ?? [];

      if (matchesList.isEmpty && decoded['data']?['matches'] != null) {
          // Fallback para uma estrutura aninhada
          // matchesList = decoded['data']['matches'];
      }

      return matchesList
          .map((item) => MatchHistoryItem.fromJson(item))
          .toList();
    } else {
      // Tenta decodificar uma mensagem de erro da API
      try {
        final decoded = json.decode(response.body);
        final message = decoded['message'] ?? 'Falha ao carregar o histórico.';
        throw Exception(message);
      } catch (e) {
        throw Exception('Falha ao carregar o histórico de partidas.');
      }
    }
  }
}