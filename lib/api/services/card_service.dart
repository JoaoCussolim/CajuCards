import 'dart:convert';
import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/models/card.dart';

class CardService {
  final ApiClient _apiClient;

  CardService(this._apiClient);

  Future<List<Card>> getAllCards() async {
    final response = await _apiClient.get('/cards', requireAuth: false);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> cardListJson = decoded['data']['cards'];

      return cardListJson.map((json) => Card.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar as cartas da API.');
    }
  }
}
