import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cajucards/models/game_state.dart';

enum MatchmakingStatus { idle, searching, inMatch, error }

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  final String _serverUrl = 'https://cajucards-api.onrender.com';

  MatchmakingStatus _status = MatchmakingStatus.idle;
  MatchmakingStatus get status => _status;

  GameState? _gameState;
  GameState? get gameState => _gameState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- 1. Conexão e Configuração dos Listeners ---
  void connectAndListen() {
    // Pega o token de acesso do Supabase para autenticação
    final String? accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    if (accessToken == null) {
      _status = MatchmakingStatus.error;
      _errorMessage = "Usuário não autenticado.";
      notifyListeners();
      return;
    }

    // Configura o socket com o token de autenticação
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': accessToken,
          }) // Envia o token para o middleware do servidor
          .build(),
    );

    // --- Listeners de Eventos do Socket ---
    _socket!.onConnect((_) {
      debugPrint('✅ Conectado ao servidor de socket!');
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Desconectado do servidor de socket.');
      _status = MatchmakingStatus.idle;
      _gameState = null;
      notifyListeners();
    });

    _socket!.onError((data) {
      debugPrint('Socket Error: $data');
      _status = MatchmakingStatus.error;
      _errorMessage = data.toString();
      notifyListeners();
    });

    // --- Listeners de Eventos do JOGO ---

    // O servidor informa que estamos na fila
    _socket!.on('waitingForOpponent', (_) {
      _status = MatchmakingStatus.searching;
      notifyListeners();
    });

    // O servidor encontrou uma partida!
    _socket!.on('matchFound', (data) {
      debugPrint('Partida encontrada! ID: ${data['matchId']}');
      // Apenas atualiza o status, o primeiro GameState virá com o 'gameStateUpdate'
      _status = MatchmakingStatus.inMatch;
      // Inicializa o estado do jogo se o servidor enviar um estado inicial aqui
      // _gameState = GameState.fromJson(data['initialState']);
      notifyListeners();
    });

    // O servidor envia o estado atualizado do jogo
    _socket!.on('gameStateUpdate', (data) {
      _gameState = GameState.fromJson(data);
      notifyListeners(); // Notifica a UI para se reconstruir com o novo estado
    });

    // O oponente jogou uma carta (se você quiser fazer animações específicas)
    _socket!.on('opponentPlayedCard', (data) {
      debugPrint('Oponente jogou uma carta: $data');
      // Você pode usar isso para disparar animações antes do 'gameStateUpdate' chegar
    });

    // O oponente desconectou
    _socket!.on('opponentLeft', (_) {
      debugPrint('Oponente desconectou.');
      // AQUI: Adicionar lógica para mostrar tela de vitória
      _status = MatchmakingStatus.idle; // Ou um estado de 'vitoria'
      _gameState = null;
      notifyListeners();
    });

    // O servidor recusou nossa jogada
    _socket!.on('actionInvalid', (data) {
      _errorMessage = data['message'];
      notifyListeners(); // Mostra um erro para o usuário
    });

    _socket!.connect();
  }

  // --- 2. Funções para Enviar Eventos (Ações do Jogador) ---

  /// Entra na fila de matchmaking no servidor.
  void findMatch() {
    if (_socket?.connected ?? false) {
      _socket!.emit('findMatch');
      _status = MatchmakingStatus.searching;
      notifyListeners();
    }
  }

  /// Sai da fila de matchmaking.
  void cancelFindMatch() {
    if (_socket?.connected ?? false) {
      _socket!.emit('cancelFindMatch');
      _status = MatchmakingStatus.idle;
      notifyListeners();
    }
  }

  /// Envia a intenção de jogar uma carta para o servidor.
  void playCard(String cardId, double positionX, double positionY) {
    if (status != MatchmakingStatus.inMatch || _gameState == null) return;

    _socket!.emit('playCard', {
      'matchId': _gameState!.matchId,
      'cardId': cardId,
      'positionX': positionX,
      'positionY': positionY,
    });
  }

  // --- 3. Limpeza ---

  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
