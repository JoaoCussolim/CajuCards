class PlayerSummary {
  final String id;
  final String username;

  PlayerSummary({
    required this.id,
    required this.username,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> json) {
    return PlayerSummary(
      id: json['id'] as String,
      username: json['username'] as String,
    );
  }
}