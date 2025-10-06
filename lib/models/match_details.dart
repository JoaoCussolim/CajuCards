import 'card.dart';
import 'player_summary.dart';

class CardInMatch {
  final String playerId;
  final int levelInMatch;
  final Card card;

  CardInMatch({
    required this.playerId,
    required this.levelInMatch,
    required this.card,
  });

  factory CardInMatch.fromJson(Map<String, dynamic> json) {
    return CardInMatch(
      playerId: json['player_id'],
      levelInMatch: json['level_in_match'],
      card: Card.fromJson(json['card']),
    );
  }
}

class MatchDetails {
  final String id;
  final DateTime matchDate;
  final PlayerSummary player1;
  final PlayerSummary player2;
  final PlayerSummary winner;
  final List<CardInMatch> cardsUsed;

  MatchDetails({
    required this.id,
    required this.matchDate,
    required this.player1,
    required this.player2,
    required this.winner,
    required this.cardsUsed,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    var cardsList = json['cards_used'] as List;
    List<CardInMatch> cardsUsedList = cardsList.map((i) => CardInMatch.fromJson(i)).toList();

    return MatchDetails(
      id: json['id'],
      matchDate: DateTime.parse(json['match_date']),
      player1: PlayerSummary.fromJson(json['player1']),
      player2: PlayerSummary.fromJson(json['player2']),
      winner: PlayerSummary.fromJson(json['winner']),
      cardsUsed: cardsUsedList,
    );
  }
}