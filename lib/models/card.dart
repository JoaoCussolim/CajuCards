class Card {
  final String id;
  final String name;
  final String description;
  final String type;
  final String synergy;
  final String rarity;
  final int chestnutCost;
  final String spritePath;
  final int health;
  final int damage;

  Card({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.synergy,
    required this.rarity,
    required this.chestnutCost,
    required this.spritePath,
    required this.health,
    required this.damage,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      synergy: json['synergy'],
      rarity: json['rarity'],
      chestnutCost: json['chestnut_cost'],
      spritePath: json['sprite_path'],
      health: json['health'],
      damage: json['damage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'synergy': synergy,
      'rarity': rarity,
      'chestnut_cost': chestnutCost,
      'sprite_path': spritePath,
      'health': health,
      'damage': damage,
    };
  }
}