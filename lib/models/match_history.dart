class MatchHistory {
  final int matchId;
  final int user1Id;
  final int user2Id;
  final int winnerId;
  final DateTime matchDate;

  MatchHistory({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.winnerId,
    required this.matchDate
  });
}