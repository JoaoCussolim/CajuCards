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

  // --- ALTERAÇÃO: MUDADO DE 'void' PARA 'Future<bool> async' ---
  Future<bool> connectAndListen() async {
    String? accessToken;
    int retries = 5; // Tentar por 1.5 segundos

    // --- ADICIONADO: Loop de espera pelo token ---
    // Isso corrige o problema do token 'null' logo após o login
    while (retries > 0) {
      accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken != null) {
        break; // Token encontrado!
      }
      debugPrint("SocketService: Aguardando accessToken... ($retries)");
      await Future.delayed(const Duration(milliseconds: 300));
      retries--;
    }
    // --- FIM DA ADIÇÃO ---

    if (accessToken == null) {
      debugPrint("SocketService: Falha ao obter accessToken após espera.");
      _status = MatchmakingStatus.error;
      _errorMessage = "Usuário não autenticado.";
      notifyListeners();
      return false; // --- ALTERAÇÃO: Retorna falha
    }

    debugPrint("SocketService: AccessToken obtido. Inicializando socket...");
    // Configura o socket com o token de autenticação
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );

    // --- Listeners de Eventos do Socket ---

    _socket!.on('connect', (_) {
      debugPrint('Socket Conectado: ${_socket!.id}');
    });

    _socket!.on('connect_error', (data) {
      debugPrint('Erro de Conexão: $data');
      _status = MatchmakingStatus.error;
      _errorMessage = 'Falha ao conectar ao servidor de jogo.';
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      debugPrint('Socket Desconectado');
      _status = MatchmakingStatus.idle;
      _gameState = null;
      notifyListeners();
    });

    _socket!.on('error', (data) {
      debugPrint('Erro do Servidor: $data');
      _status = MatchmakingStatus.error;
      _errorMessage = data['message'] ?? 'Erro desconhecido do servidor.';
      notifyListeners();
    });

    // Evento principal: Partida encontrada!
// DENTRO DE connectAndListen() EM socket_service.dart

    _socket!.on('matchFound', (data) {
      debugPrint("SocketService: MatchFound! Data RAW: $data");

      final gameStateMap = data as Map<String, dynamic>;

      try {
        _gameState = GameState.fromJson(gameStateMap);
        _status = MatchmakingStatus.inMatch;
        notifyListeners();
        debugPrint("SocketService: GameState pareado com sucesso. Status: $_status");
      } catch (e) {
        debugPrint("SocketService: Erro ao parear GameState.fromJson: $e");
        // Lidar com o erro, talvez voltando ao status 'idle'
        _status = MatchmakingStatus.error;
        _errorMessage = "Erro ao carregar dados da partida.";
        notifyListeners();
      }
    });

    // Evento principal: O estado do jogo foi atualizado
    _socket!.on('gameStateUpdate', (data) {
      _gameState = GameState.fromJson(data);
      notifyListeners();
    });

    // Oponente desconectou
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
    return true; // --- ALTERAÇÃO: Retorna sucesso
  }

  // --- 2. Funções para Enviar Eventos (Ações do Jogador) ---

  // --- FUNÇÃO ALTERADA E SIMPLIFICADA ---
  // A lógica de conexão agora é GARANTIDA pela LoginScreen.
  // Se _socket for nulo aqui, é um erro de programação que deve ser reportado.
  void findMatch() {
    // 1. Define o status
    _status = MatchmakingStatus.searching;
    _errorMessage = null;
    notifyListeners();

    // 2. Verifica se o socket está conectado
    if (_socket?.connected ?? false) {
      debugPrint("SocketService: findMatch() chamado. Emitindo...");
      _socket!.emit('findMatch');
    } 
    // 3. Verifica se o socket existe, mas não está conectado (ex: rede caiu)
    else if (_socket != null && !_socket!.connected) {
      debugPrint("SocketService: findMatch() chamado, mas socket não conectado. Tentando conectar...");
      _socket!.connect(); // Tenta reconectar
      // Ouve o evento de conexão APENAS UMA VEZ
      _socket!.once('connect', (_) {
        debugPrint("SocketService: Reconectado! Emitindo findMatch...");
         if (_status == MatchmakingStatus.searching) { // Garante que o usuário não cancelou
            _socket!.emit('findMatch');
         }
      });
    } 
    // 4. Se o socket for nulo, algo deu errado no login.
    else {
      debugPrint("SocketService: findMatch() FALHOU. _socket é nulo. A conexão no login falhou.");
      _status = MatchmakingStatus.error;
      _errorMessage = "Erro de conexão. Tente fazer login novamente.";
      notifyListeners();
    }
  }
  // --- FIM DA ALTERAÇÃO ---


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
      'cardId': cardId,
      'position': {'x': positionX, 'y': positionY},
    });
  }

  /// Envia um emote para o oponente.
  void sendEmote(String emoteId) {
    if (status != MatchmakingStatus.inMatch || _gameState == null) return;

    _socket!.emit('sendEmote', {
      'emoteId': emoteId,
    });
  }

  /// Desconecta do socket.
  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}