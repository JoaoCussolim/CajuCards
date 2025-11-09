enum CardType { troop, spell, biome }

CardType _parseCardType(String rawType) {
  switch (rawType.toLowerCase()) {
    case 'troop':
      return CardType.troop;
    case 'spell':
      return CardType.spell;
    case 'biome':
      return CardType.biome;
    default:
      throw FormatException('Tipo de carta desconhecido: $rawType');
  }
}

String _cardTypeToJson(CardType type) => type.name;

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Valor "$key" inválido: $value');
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Valor "$key" inválido: $value');
}

abstract class Card {
  final String id;
  final String name;
  final String description;
  final CardType type;
  final String synergy;
  final String rarity;
  final int chestnutCost;
  final String spritePath;

  const Card({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.synergy,
    required this.rarity,
    required this.chestnutCost,
    required this.spritePath,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    final rawType = _requireString(json, 'type');
    final type = _parseCardType(rawType);

    final id = _requireString(json, 'id');
    final name = _requireString(json, 'name');
    final description = _requireString(json, 'description');
    final synergy = _requireString(json, 'synergy');
    final rarity = _requireString(json, 'rarity');
    final chestnutCost = _requireInt(json, 'chestnut_cost');
    final spritePath = _requireString(json, 'sprite_path');

    switch (type) {
      case CardType.troop:
        final health = json['health'];
        final damage = json['damage'];
        if (health == null || damage == null) {
          throw const FormatException(
              'Cartas do tipo tropa exigem os campos "health" e "damage".');
        }
        return TroopCard(
          id: id,
          name: name,
          description: description,
          synergy: synergy,
          rarity: rarity,
          chestnutCost: chestnutCost,
          spritePath: spritePath,
          health: _requireInt(json, 'health'),
          damage: _requireInt(json, 'damage'),
        );
      case CardType.spell:
        final radius = json['radius'];
        final damage = json['damage'];
        final parsedRadius =
            radius is num ? radius.toDouble() : null;
        final parsedDamage = damage is num ? damage.toInt() : null;
        return SpellCard(
          id: id,
          name: name,
          description: description,
          synergy: synergy,
          rarity: rarity,
          chestnutCost: chestnutCost,
          spritePath: spritePath,
          radius: parsedRadius,
          damage: parsedDamage,
        );
      case CardType.biome:
        final enabledSynergiesRaw = json['enabled_synergies'];
        List<String>? enabledSynergies;
        if (enabledSynergiesRaw is List) {
          enabledSynergies = enabledSynergiesRaw
              .whereType<String>()
              .toList(growable: false);
        }
        return BiomeCard(
          id: id,
          name: name,
          description: description,
          synergy: synergy,
          rarity: rarity,
          chestnutCost: chestnutCost,
          spritePath: spritePath,
          enabledSynergies: enabledSynergies,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': _cardTypeToJson(type),
      'synergy': synergy,
      'rarity': rarity,
      'chestnut_cost': chestnutCost,
      'sprite_path': spritePath,
    };
  }
}

class TroopCard extends Card {
  final int health;
  final int damage;

  TroopCard({
    required super.id,
    required super.name,
    required super.description,
    required super.synergy,
    required super.rarity,
    required super.chestnutCost,
    required super.spritePath,
    required this.health,
    required this.damage,
  }) : super(type: CardType.troop);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'health': health,
      'damage': damage,
    });
    return json;
  }
}

class SpellCard extends Card {
  final double? radius;
  final int? damage;

  SpellCard({
    required super.id,
    required super.name,
    required super.description,
    required super.synergy,
    required super.rarity,
    required super.chestnutCost,
    required super.spritePath,
    this.radius,
    this.damage,
  }) : super(type: CardType.spell);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (radius != null) {
      json['radius'] = radius;
    }
    if (damage != null) {
      json['damage'] = damage;
    }
    return json;
  }
}

class BiomeCard extends Card {
  final List<String>? enabledSynergies;

  BiomeCard({
    required super.id,
    required super.name,
    required super.description,
    required super.synergy,
    required super.rarity,
    required super.chestnutCost,
    required super.spritePath,
    this.enabledSynergies,
  }) : super(type: CardType.biome);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (enabledSynergies != null) {
      json['enabled_synergies'] = enabledSynergies;
    }
    return json;
  }
}
