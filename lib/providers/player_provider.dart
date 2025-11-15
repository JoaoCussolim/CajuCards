import 'package:flutter/material.dart';
import 'package:cajucards/models/player.dart';
import 'package:cajucards/models/emote.dart';
import 'package:cajucards/models/match_history_item.dart'; // 1. Importar o novo modelo
import 'package:cajucards/api/services/user_service.dart';
import 'package:cajucards/api/services/shop_service.dart';
import 'package:cajucards/api/services/match_history_service.dart'; // 2. Importar o novo serviço
import 'package:cajucards/api/api_client.dart';

class PlayerProvider with ChangeNotifier {
  final UserService _userService;
  final ShopService _shopService;
  final MatchHistoryService _matchHistoryService; // 3. Adicionar o serviço de histórico

  Player? _player;
  bool _isLoading = false;
  String? _error;

  // Estados para controlar o processo de compra
  bool _isBuyingChest = false;
  String? _buyChestError;
  Emote? _lastWonEmote;

  // 4. Estados para controlar o histórico de partidas
  List<MatchHistoryItem> _matches = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // 5. Construtor atualizado
  PlayerProvider({required ApiClient apiClient})
      : _userService = UserService(apiClient),
        _shopService = ShopService(apiClient),
        _matchHistoryService = MatchHistoryService(apiClient); // Inicializa o serviço

  // Getters
  Player? get player => _player;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isBuyingChest => _isBuyingChest;
  String? get buyChestError => _buyChestError;
  Emote? get lastWonEmote => _lastWonEmote;

  // 6. Getters para os novos estados de histórico
  List<MatchHistoryItem> get matches => _matches;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;


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
    _matches = []; // Limpa o histórico ao deslogar
    notifyListeners();
  }

  // ... (método buyChest não modificado) ...
  Future<bool> buyChest(String chestName, int price) async {
    _isBuyingChest = true;
    _buyChestError = null;
    _lastWonEmote = null;
    notifyListeners();

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
      final Map<String, dynamic> responseData =
          await _shopService.buyChest(chestName);

      _player = Player.fromJson(responseData['player'] as Map<String, dynamic>);
      _lastWonEmote = Emote.fromJson(responseData['emote'] as Map<String, dynamic>);

      _isBuyingChest = false;
      notifyListeners();
      return true; 

    } catch (e) {
      _buyChestError = e.toString().replaceFirst("Exception: ", "");
      _isBuyingChest = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpa a mensagem de erro da compra de baú.
  void clearBuyChestError() {
    _buyChestError = null;
    notifyListeners();
  }

  // 7. NOVO MÉTODO: Buscar o histórico de partidas
  Future<void> fetchMatchHistory() async {
    // Evita buscas repetidas se já estiver carregando
    if (_isLoadingHistory) return;

    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      _matches = await _matchHistoryService.getMatchHistory();
    } catch (e) {
      _historyError = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
}