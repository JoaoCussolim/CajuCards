import 'dart:convert';
import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/models/player.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<Player> getUserProfile() async {
    final response = await _apiClient.get('/users/me', requireAuth: true);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return Player.fromJson(decoded['data']['user']);
    } else {
      throw Exception('Falha ao carregar o perfil do cajuicer.');
    }
  }

  Future<void> addUserEmote(String emoteId) async {
    final response = await _apiClient.post(
      '/users/me/emotes',
      body: {'emote_id': emoteId},
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao adicionar o emote.');
    }
  }
}
