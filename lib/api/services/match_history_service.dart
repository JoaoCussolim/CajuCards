// lib/services/match_history_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Importar para debugPrint
import 'package:http/http.dart' as http;
import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/models/match_history_item.dart';

class MatchHistoryService {
  final ApiClient _apiClient;

  MatchHistoryService(this._apiClient);

  /// Busca o histórico de partidas do usuário logado.
  Future<List<MatchHistoryItem>> getMatchHistory() async {
    try {
      // Chama o endpoint GET /api/match-history com autenticação
      final http.Response response = await _apiClient.get(
        '/match-history',
        requireAuth: true,
      );

      // =========== DEBUGGING ============
      debugPrint("========================================");
      debugPrint("Match History API Response");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("========================================");
      // ====================================

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Extrai a lista de 'matches' dos dados da resposta
        final List<dynamic> matchesList = responseData['data']['matches'];

        // =========== DEBUGGING ============
        debugPrint("Sucesso: ${matchesList.length} partidas encontradas no JSON.");
        // ====================================
        
        // Converte a lista de JSON para uma lista de MatchHistoryItem
        return matchesList
            .map((matchJson) => MatchHistoryItem.fromJson(matchJson as Map<String, dynamic>))
            .toList();
      } else {
        // Trata erros da API
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Falha ao buscar histórico');
      }
    } catch (e) {
      // =========== DEBUGGING ============
      // Se a desserialização (Json.decode ou fromJson) falhar, cairá aqui.
      debugPrint("ERRO no try/catch do MatchHistoryService: ${e.toString()}");
      // ====================================
      
      // Repassa a exceção
      throw Exception('Erro de rede ou servidor: ${e.toString()}');
    }
  }
}