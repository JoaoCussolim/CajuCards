class Card {
  final int cardId;
  final String spritePath;
  final String cardModel;
  final String name;
  final String type;
  final String sinergy;
  final String rarity;
  final int price;
  final int health;
  final int damage;

  Card({
    required this.cardId,
    required this.spritePath, 
    required this.cardModel,
    required this.name,
    required this.type,
    required this.sinergy,
    required this.rarity,
    required this.price, 
    required this.health, 
    required this.damage
  });
}