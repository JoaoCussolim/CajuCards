// lib/providers/player_provider.dart

import 'package:flutter/material.dart';
import 'package:cajucards/models/player.dart';
import 'package:cajucards/api/services/user_service.dart';
import 'package:cajucards/api/api_client.dart';

class PlayerProvider with ChangeNotifier {
  final UserService _userService = UserService(ApiClient());
  Player? _player;
  bool _isLoading = false;
  String? _error;

  Player? get player => _player;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> fetchAndSetPlayer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _player = await _userService.getUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Falha ao carregar os dados do jogador.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearPlayer() {
    _player = null;
    notifyListeners();
  }
}
