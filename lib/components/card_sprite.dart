// Em lib/components/card_sprite.dart (ou onde você a criou)
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // Precisamos para o TextStyle
import 'package:cajucards/models/card.dart' as card_model;
import 'package:cajucards/api/services/socket_service.dart';

// Defina o tamanho da sua carta
final Vector2 cardSize = Vector2(100, 140);

class CardSprite extends PositionComponent with TapCallbacks {
  final card_model.Card card;
  final SocketService socketService;

  CardSprite({required this.card, required this.socketService})
    : super(size: cardSize);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final backgroundPath = 'images/sprites/background/${card.synergy}.png';
    final borderPath = 'images/sprites/border/${card.rarity}.png';
    final characterPath = 'images/sprites/${card.spritePath}';

    final synergyBackground = SpriteComponent(
      sprite: await Sprite.load(backgroundPath),
      size: size,
    );

    // 3. Carrega a borda baseada na raridade (Carbon, Mercury, etc.)
    final rarityBorder = SpriteComponent(
      sprite: await Sprite.load(borderPath),
      size: size,
    );

    // 4. Carrega o sprite do personagem
    final characterSprite = SpriteComponent(
      sprite: await Sprite.load(characterPath),
      size: size * 0.7, // Ajuste o tamanho do sprite como preferir
      anchor: Anchor.center,
      position: size / 2, // Centraliza o sprite na carta
    );

    // 5. Adiciona o CUSTO da carta
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
      position: Vector2(
        size.x * 0.26,
        size.y * 0.23,
      ), // Posição na "tag" laranja
    );

    add(synergyBackground);
    add(characterSprite);
    add(rarityBorder);
    add(costText); // O custo fica por cima de tudo
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    print('Carta clicada: ${card.name}');
    final gamePosition = event.canvasPosition;
    socketService.playCard(card.id, gamePosition.x, gamePosition.y);
  }
}
