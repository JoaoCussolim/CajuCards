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

    // --- CAMINHOS DOS ASSETS ---
    // Estrutura de pastas que vimos na imagem
    final backgroundPath = 'sprites/background/${card.synergy}.png';
    final borderPath = 'sprites/border/${card.rarity}.png';
    final characterPath = 'sprites/${card.spritePath}';

    final synergyBackground = SpriteComponent(
      sprite: await Sprite.load(backgroundPath),
      size: size,
    );

    // 2. Carrega a imagem base da carta (a que você mandou)
    final cardBase = SpriteComponent(
      sprite: await Sprite.load('card_base.png'), // << NOME DO SEU ARQUIVO
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
        size.x * 0.22,
        size.y * 0.15,
      ), // Posição na "tag" laranja
    );

    // Adiciona os componentes na ordem de pintura (de baixo para cima)
    add(synergyBackground);
    add(cardBase);
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
