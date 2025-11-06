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
    int coins = 0;
    final coinsValue = json['cashew_coins'];

    if (coinsValue is int) {
      coins = coinsValue;
    } else if (coinsValue is String) {
      coins = int.tryParse(coinsValue) ?? 0; 
    }
    
    return Player(
      id: json['id'],
      username: json['username'],
      cashewCoins: coins,
    );
  }
}