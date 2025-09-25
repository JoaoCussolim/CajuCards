class Player {
  final String id;
  final String username;
  final int cashewCoins;

  Player({
    required this.id,
    required this.username,
    required this.cashewCoins,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      username: json['username'],
      cashewCoins: json['cashew_coins'],
    );
  }
}