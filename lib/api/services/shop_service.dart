// lib/api/services/shop_service.dart
import 'dart:convert';
import 'package:cajucards/api/api_client.dart';
import 'package:http/http.dart' as http; // Apenas para referência, já está no ApiClient

class ShopService {
  final ApiClient _apiClient;

  ShopService(this._apiClient);

  /// Chama a API para comprar um baú.
  Future<Map<String, dynamic>> buyChest(String chestName) async {
    final response = await _apiClient.post(
      '/shop/buy-chest',
      body: {'chest_name': chestName},
    );

    final decoded = json.decode(response.body);
    if (response.statusCode == 200) {
      if (decoded['status'] == 'success' &&
          decoded['data'] != null &&
          decoded['data']['player'] != null &&
          decoded['data']['emote'] != null) {
        
        return decoded['data']; // SUCESSO REAL

      } else {
        final message = decoded['message'] ?? 'Resposta da API em formato inesperado.';
        throw Exception(message);
      }

    } else {
      final message = decoded['message'] ?? 'Erro desconhecido ao comprar o baú.';
      throw Exception(message);
    }
  }
}