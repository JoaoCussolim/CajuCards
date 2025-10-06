import 'player_summary.dart';

class MatchHistoryItem {
  final String id;
  final DateTime matchDate;
  final PlayerSummary player1;
  final PlayerSummary player2;
  final PlayerSummary winner;

  MatchHistoryItem({
    required this.id,
    required this.matchDate,
    required this.player1,
    required this.player2,
    required this.winner,
  });

  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return MatchHistoryItem(
      id: json['id'],
      matchDate: DateTime.parse(json['match_date']),
      player1: PlayerSummary.fromJson(json['player1']),
      player2: PlayerSummary.fromJson(json['player2']),
      winner: PlayerSummary.fromJson(json['winner']),
    );
  }
}