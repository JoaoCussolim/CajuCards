// lib/providers/player_provider.dart

import 'package:flutter/material.dart';
import 'package:cajucards/models/player.dart';
import 'package:cajucards/models/emote.dart'; // 1. Importar o modelo Emote
import 'package:cajucards/api/services/user_service.dart';
import 'package:cajucards/api/services/shop_service.dart'; // 2. Importar o novo ShopService
import 'package:cajucards/api/api_client.dart';

class PlayerProvider with ChangeNotifier {
  final UserService _userService;
  final ShopService _shopService; // 3. Adicionar a instância do ShopService

  Player? _player;
  bool _isLoading = false;
  String? _error;

  // 4. Estados para controlar o processo de compra
  bool _isBuyingChest = false;
  String? _buyChestError;
  Emote? _lastWonEmote;

  // 5. Construtor atualizado para receber o ApiClient
  PlayerProvider({required ApiClient apiClient})
      : _userService = UserService(apiClient),
        _shopService = ShopService(apiClient);

  // 6. Getters para os novos estados
  Player? get player => _player;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isBuyingChest => _isBuyingChest;
  String? get buyChestError => _buyChestError;
  Emote? get lastWonEmote => _lastWonEmote;

  /// Busca os dados do jogador logado.
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

  // 7. MÉTODO PRINCIPAL: Comprar o Baú (com chamada de API real)
  Future<bool> buyChest(String chestName, int price) async {
    _isBuyingChest = true;
    _buyChestError = null;
    _lastWonEmote = null;
    notifyListeners();

    // 8. Verificação de moedas no lado do cliente (para feedback rápido)
    if (_player == null) {
      _buyChestError = "Jogador não encontrado.";
      _isBuyingChest = false;
      notifyListeners();
      return false;
    }

    if (_player!.cashewCoins < price) {
      _buyChestError = "Moedas insuficientes!";
      _isBuyingChest = false;
      notifyListeners();
      return false;
    }

    try {
      // 9. Chamar o serviço que chama a API
      final Map<String, dynamic> responseData =
          await _shopService.buyChest(chestName);

      // 10. Processar a resposta de sucesso da API
      _player = Player.fromJson(responseData['player'] as Map<String, dynamic>);
      _lastWonEmote = Emote.fromJson(responseData['emote'] as Map<String, dynamic>);

      _isBuyingChest = false;
      notifyListeners();
      return true; // Sucesso!

    } catch (e) {
      // 11. Processar erro (vindo do ShopService ou de rede)
      // Remove o "Exception: " da mensagem de erro
      _buyChestError = e.toString().replaceFirst("Exception: ", "");
      _isBuyingChest = false;
      notifyListeners();
      return false; // Falha
    }
  }

  /// Limpa a mensagem de erro da compra de baú.
  void clearBuyChestError() {
    _buyChestError = null;
    notifyListeners();
  }
}