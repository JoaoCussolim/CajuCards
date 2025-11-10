import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:cajucards/models/card.dart' as card_model;
import 'package:cajucards/screens/playground.dart';

final Vector2 cardSize = Vector2(100, 140);

class CardSprite extends PositionComponent with TapCallbacks {
  final card_model.Card card;
  final CajuPlaygroundGame game;

  CardSprite({
    required this.card,
    required this.game,
  }) : super(size: cardSize);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    const basePath = 'assets/images/sprites';
    final backgroundPath = '$basePath/background/${card.synergy}.png';
    final borderPath = '$basePath/border/${card.rarity}.png';
    final characterPath = '$basePath/${card.spritePath}';

    final synergyBackground = SpriteComponent(
      sprite: await Sprite.load(backgroundPath),
      size: size,
    );

    final rarityBorder = SpriteComponent(
      sprite: await Sprite.load(borderPath),
      size: size,
    );

    final characterSprite = SpriteComponent(
      sprite: await Sprite.load(characterPath),
      size: size * 0.7,
      anchor: Anchor.center,
      position: size / 2,
    );

    final textStyle = TextPaint(
      style: const TextStyle(
        fontFamily: 'VT323',
        fontSize: 24,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(2, 2)),
        ],
      ),
    );

    final costText = TextComponent(
      text: card.chestnutCost.toString(),
      textRenderer: textStyle,
      anchor: Anchor.center,
      position: Vector2(size.x * 0.26, size.y * 0.23),
    );

    add(synergyBackground);
    add(characterSprite);
    add(rarityBorder);
    add(costText);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (game.currentEnergy < card.chestnutCost) {
      print('Energia insuficiente para: ${card.name}');
      return;
    }

    if (card is card_model.BiomeCard) {
      game.currentEnergy -= card.chestnutCost;
      unawaited(game.applyBackgroundBiome(card.synergy));
      print('Aplicando bioma: ${card.name}');
      return;
    }

    if (card is card_model.SpellCard) {
      final spellCard = card as card_model.SpellCard;
      game.currentEnergy -= spellCard.chestnutCost;
      game.castSpell(spellCard);
      return;
    }

    if (card is! card_model.TroopCard) {
      print('Tipo de carta desconhecido: ${card.type}');
      return;
    }

    final troopCard = card as card_model.TroopCard;

    if (!game.canSummonCreatureWithSynergy(troopCard.synergy)) {
      print(
          'Limite de sinergias atingido. Não é possível invocar ${troopCard.name}.');
      return;
    }

    game.currentEnergy -= troopCard.chestnutCost;

    print('Invocando: ${troopCard.name}');
    game.spawnCreatureAndAttack(troopCard);
  }
}
