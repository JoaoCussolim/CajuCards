import 'dart:ui';

import 'package:cajucards/models/card.dart' as card_model;
import 'package:cajucards/screens/playground.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final Vector2 cardSize = Vector2(100, 140);

String _resolveSpriteAssetPath(String rawPath) {
  if (rawPath.startsWith('assets/')) {
    return rawPath;
  }
  if (rawPath.startsWith('images/')) {
    return 'assets/$rawPath';
  }
  if (rawPath.startsWith('sprites/')) {
    return 'assets/images/$rawPath';
  }
  if (!rawPath.contains('/')) {
    return 'assets/images/sprites/$rawPath';
  }
  return 'assets/images/$rawPath';
}

class CardSprite extends PositionComponent with TapCallbacks {
  final card_model.Card card;
  final CajuPlaygroundGame game;
  late final RectangleComponent _selectionOutline;

  CardSprite({
    required this.card,
    required this.game,
  }) : super(size: cardSize);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    const basePath = 'sprites';
    final backgroundPath =
        _resolveSpriteAssetPath('$basePath/background/${card.synergy}.png');
    final borderPath =
        _resolveSpriteAssetPath('$basePath/border/${card.rarity}.png');
    final characterPath = _resolveSpriteAssetPath(card.spritePath);

    final backgroundSprite = await _loadSpriteOrNull(backgroundPath);
    final borderSprite = await _loadSpriteOrNull(borderPath);
    final characterSprite = await _loadSpriteOrNull(characterPath);

    if (backgroundSprite != null) {
      add(
        SpriteComponent(
          sprite: backgroundSprite,
          size: size,
        ),
      );
    } else {
      add(
        RectangleComponent(
          size: size,
          paint: Paint()..color = Colors.black.withOpacity(0.65),
        ),
      );
    }

    if (characterSprite != null) {
      add(
        SpriteComponent(
          sprite: characterSprite,
          size: size * 0.7,
          anchor: Anchor.center,
          position: size / 2,
        ),
      );
    }

    if (borderSprite != null) {
      add(
        SpriteComponent(
          sprite: borderSprite,
          size: size,
        ),
      );
    } else {
      add(
        RectangleComponent(
          size: size,
          paint: Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    }

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

    add(costText);

    _selectionOutline = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
      paint: Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    )
      ..priority = 10
      ..opacity = 0;

    add(_selectionOutline);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (game.currentEnergy < card.chestnutCost) {
      print('Energia insuficiente para: ${card.name}');
      return;
    }

    if (card is card_model.SpellCard) {
      final spellCard = card as card_model.SpellCard;
      game.prepareSpell(spellCard, this);
      event.handled = true;
      return;
    }

    if (card is! card_model.TroopCard) {
      debugPrint('Carta não suportada: ${card.type} (${card.name})');
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

  void setSelected(bool selected) {
    _selectionOutline.opacity = selected ? 1 : 0;
  }

  Future<Sprite?> _loadSpriteOrNull(String path) async {
    try {
      return await Sprite.load(path);
    } catch (error, stackTrace) {
      debugPrint('Falha ao carregar sprite "$path": $error');
      debugPrint('$stackTrace');
      return null;
    }
  }
}
