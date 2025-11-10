// lib/providers/player_provider.dart

import 'package:flutter/material.dart';
import 'package:cajucards/models/player.dart';
import 'package:cajucards/models/emote.dart';
import 'package:cajucards/models/match_history_item.dart'; // 1. Importar modelo de histórico
import 'package:cajucards/api/services/user_service.dart';
import 'package:cajucards/api/services/shop_service.dart';
import 'package:cajucards/api/services/match_service.dart'; // 2. Importar o novo MatchService
import 'package:cajucards/api/api_client.dart';

class PlayerProvider with ChangeNotifier {
  final UserService _userService;
  final ShopService _shopService;
  final MatchService _matchService; // 3. Adicionar a instância do MatchService

  Player? _player;
  bool _isLoading = false;
  String? _error;

  // Estados para controlar o processo de compra
  bool _isBuyingChest = false;
  String? _buyChestError;
  Emote? _lastWonEmote;

  // 4. Estados para controlar o histórico de partidas
  List<MatchHistoryItem>? _matches;
  bool _isLoadingMatches = false;
  String? _matchesError;

  // 5. Construtor atualizado
  PlayerProvider({required ApiClient apiClient})
      : _userService = UserService(apiClient),
        _shopService = ShopService(apiClient),
        _matchService = MatchService(apiClient); // Inicializa o MatchService

  // 6. Getters
  Player? get player => _player;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isBuyingChest => _isBuyingChest;
  String? get buyChestError => _buyChestError;
  Emote? get lastWonEmote => _lastWonEmote;

  // Getters para o histórico de partidas
  List<MatchHistoryItem>? get matches => _matches;
  bool get isLoadingMatches => _isLoadingMatches;
  String? get matchesError => _matchesError;

  /// Busca os dados do jogador logado. (Mantido do seu código)
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
    _matches = null; // Limpa o histórico também
    notifyListeners();
  }

  // 7. NOVO MÉTODO: Buscar histórico de partidas
  Future<void> fetchMatchHistory() async {
    // Evita buscas duplicadas se já estiver carregando
    if (_isLoadingMatches) return;

    _isLoadingMatches = true;
    _matchesError = null;
    notifyListeners();

    try {
      // Chama o novo serviço
      _matches = await _matchService.getMatchHistory();
    } catch (e) {
      _matchesError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  // MÉTODO PRINCIPAL: Comprar o Baú (Mantido do seu código)
  Future<bool> buyChest(String chestName, int price) async {
    _isBuyingChest = true;
    _buyChestError = null;
    _lastWonEmote = null;
    notifyListeners();

    // Verificação de moedas no lado do cliente
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
      // Chamar o serviço que chama a API
      final Map<String, dynamic> responseData =
          await _shopService.buyChest(chestName);

      // Processar a resposta de sucesso da API
      _player = Player.fromJson(responseData['player'] as Map<String, dynamic>);
      _lastWonEmote = Emote.fromJson(responseData['emote'] as Map<String, dynamic>);

      _isBuyingChest = false;
      notifyListeners();
      return true; // Sucesso!

    } catch (e) {
      // Processar erro
      _buyChestError = e.toString().replaceFirst("Exception: ", "");
      _isBuyingChest = false;
      notifyListeners();
      return false; // Falha
    }
  }

  /// Limpa a mensagem de erro da compra de baú. (Mantido do seu código)
  void clearBuyChestError() {
    _buyChestError = null;
    notifyListeners();
  }
}