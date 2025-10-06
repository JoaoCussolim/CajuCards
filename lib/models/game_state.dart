import 'package:cajucards/models/player.dart';

class PlayerMatchState {
  final String id;
  final String username;
  final int health;
  final int energy;

  PlayerMatchState({
    required this.id,
    required this.username,
    required this.health,
    required this.energy,
  });

  factory PlayerMatchState.fromJson(Map<String, dynamic> json) {
    return PlayerMatchState(
      id: json['id'],
      username: json['username'],
      health: json['health'],
      energy: json['energy'],
    );
  }
}

class GameState {
  final String matchId;
  final Map<String, PlayerMatchState> players;
  // Adicione aqui outros campos, como a lista de tropas no tabuleiro
  // final List<Tropa> board;

  GameState({required this.matchId, required this.players});

  factory GameState.fromJson(Map<String, dynamic> json) {
    var playersMap = Map<String, dynamic>.from(json['players']);
    return GameState(
      matchId: json['matchId'],
      players: playersMap.map(
        (key, value) => MapEntry(key, PlayerMatchState.fromJson(value)),
      ),
    );
  }
}
