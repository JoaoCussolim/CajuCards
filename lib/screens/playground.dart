import 'dart:math' as math;
import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/api/services/card_service.dart';
import 'package:cajucards/api/services/socket_service.dart';
import 'package:cajucards/components/card_sprite.dart';
import 'package:cajucards/components/creature_sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:cajucards/models/card.dart' as card_model;

class ArenaLane extends RectangleComponent {
  ArenaLane({
    required Vector2 size,
    required Vector2 position,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF363B57),
        );
}

class RiverComponent extends RectangleComponent {
  RiverComponent({
    required Vector2 size,
    required Vector2 position,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF2B7A9E),
        );
}

class TowerSlotComponent extends RectangleComponent {
  TowerSlotComponent({
    required Vector2 size,
    required Vector2 position,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.center,
          paint: Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
}

class TowerComponent extends RectangleComponent {
  TowerComponent({
    required Vector2 size,
    required Vector2 position,
    required Anchor anchor,
    bool isOpponent = false,
  }) : super(
          size: size,
          position: position,
          anchor: anchor,
          paint: Paint()
            ..color = isOpponent
                ? const Color(0xFFc34a36)
                : const Color(0xFF3fc380),
        );
}

class Enemy extends SpriteComponent {
  Enemy() : super(size: Vector2.all(80));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load('images/sprites/robot.png');
  }
}

class CajuPlaygroundGame extends FlameGame with TapCallbacks {
  final SocketService socketService;
  CajuPlaygroundGame({required this.socketService});

  double currentEnergy = 0.0;
  final double maxEnergy = 10.0;
  final double energyPerSecond = 1.0;
  late final TextComponent energyText;
  final ValueNotifier<double> energyRatioNotifier = ValueNotifier(0);
  Enemy? enemy;

  @override
  Color backgroundColor() => const Color(0xFF2a2e42);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _buildArena();

    final textStyle = TextPaint(
      style: const TextStyle(
        fontFamily: 'VT323',
        fontSize: 24,
        color: Colors.white,
      ),
    );
    energyText = TextComponent(
      text: 'Energia: 0/10',
      textRenderer: textStyle,
      position: Vector2(size.x - 20, 20),
      anchor: Anchor.topRight,
    );
    add(energyText);

    enemy = Enemy()
      ..position =
          Vector2(size.x / 2, size.y * 0.25)
      ..anchor = Anchor.center;
    add(enemy!);

    final cardService = CardService(ApiClient());

    try {
      print("Buscando cartas...");
      final List<card_model.Card> allCards = await cardService.getAllCards();
      print("Recebidas ${allCards.length} cartas.");

      if (allCards.isEmpty) {
        print("Nenhuma carta encontrada na API.");
        return;
      }

      double xPos = 50.0;
      double yPos = size.y - 150.0;
      const double xGap = 120.0;

      for (var cardData in allCards) {
        final cardSprite = CardSprite(
          card: cardData,
          game: this,
        )..position = Vector2(xPos, yPos);

        add(cardSprite);

        xPos += xGap;
        if (xPos + cardSize.x > size.x) {
          xPos = 50.0;
          yPos -= (cardSize.y + 20);
        }
      }
    } catch (e, stackTrace) {
      print("--- ERRO AO CARREGAR CARTAS DA API ---");
      print(e);
      print(stackTrace);
    }
  }

  void _buildArena() {
    final laneWidth = size.x * 0.85;
    final laneHeight = size.y * 0.2;
    final riverHeight = size.y * 0.04;

    add(ArenaLane(
      size: Vector2(laneWidth, laneHeight),
      position: Vector2(size.x / 2, size.y / 2),
    ));

    add(RiverComponent(
      size: Vector2(laneWidth, riverHeight),
      position: Vector2(size.x / 2, size.y / 2),
    ));

    final slotCount = 3;
    final slotWidth = laneWidth / (slotCount + 1);
    final slotHeight = size.y * 0.1;
    final slotSpacing = slotWidth * 0.1;
    final totalSlotsWidth = slotCount * slotWidth + (slotCount - 1) * slotSpacing;
    final startX = (size.x - totalSlotsWidth) / 2 + slotWidth / 2;
    final bottomY = size.y * 0.7;
    final topY = size.y * 0.3;

    for (var i = 0; i < slotCount; i++) {
      final x = startX + i * (slotWidth + slotSpacing);
      add(TowerSlotComponent(
        size: Vector2(slotWidth, slotHeight),
        position: Vector2(x, bottomY),
      ));
      add(TowerSlotComponent(
        size: Vector2(slotWidth, slotHeight),
        position: Vector2(x, topY),
      ));
    }

    final towerSize = Vector2(size.x * 0.12, size.y * 0.18);
    final horizontalPadding = size.x * 0.05;
    final verticalPadding = size.y * 0.05;

    add(TowerComponent(
      size: towerSize,
      position: Vector2(horizontalPadding, size.y - verticalPadding),
      anchor: Anchor.bottomLeft,
    ));

    add(TowerComponent(
      size: towerSize,
      position: Vector2(size.x - horizontalPadding, size.y - verticalPadding),
      anchor: Anchor.bottomRight,
    ));

    add(TowerComponent(
      size: towerSize,
      position: Vector2(horizontalPadding, verticalPadding),
      anchor: Anchor.topLeft,
      isOpponent: true,
    ));

    add(TowerComponent(
      size: towerSize,
      position: Vector2(size.x - horizontalPadding, verticalPadding),
      anchor: Anchor.topRight,
      isOpponent: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentEnergy < maxEnergy) {
      currentEnergy += energyPerSecond * dt;
      if (currentEnergy > maxEnergy) {
        currentEnergy = maxEnergy;
      }
    }
    energyText.text = 'Energia: ${currentEnergy.floor()}/${maxEnergy.floor()}';
    energyRatioNotifier.value = currentEnergy / maxEnergy;
  }

  @override
  void onRemove() {
    energyRatioNotifier.dispose();
    super.onRemove();
  }

  void spawnCreatureAndAttack(card_model.Card cardData) {
    if (enemy == null) return;

    final creature = CreatureSprite(cardData: cardData)
      ..position =
          size /
          2
      ..anchor = Anchor.center;

    add(creature);

    final pause = MoveEffect.by(
      Vector2.zero(),
      EffectController(duration: 0.1),
    );

    const double attackAngle = math.pi / 4;
    final attack = RotateEffect.to(
      attackAngle,
      EffectController(
        duration: 0.15,
        reverseDuration: 0.15,
      ),
    );

    final move = MoveEffect.to(
      enemy!.position,
      EffectController(duration: 0.5, curve: Curves.easeInOut),
    );

    final remove = RemoveEffect();

    final sequence = SequenceEffect([
      pause,
      attack,
      move,
      remove,
    ]);

    creature.add(sequence);
  }
}

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final CajuPlaygroundGame _game;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _game = CajuPlaygroundGame(socketService: _socketService);
    // _socketService.connectAndListen(); // Podemos desabilitar para a simulação
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CajuCards Playground'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'energyHud': (context, game) {
            final cajuGame = game as CajuPlaygroundGame;
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: ValueListenableBuilder<double>(
                    valueListenable: cajuGame.energyRatioNotifier,
                    builder: (context, ratio, _) {
                      final clampedRatio = ratio.clamp(0.0, 1.0);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: clampedRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF88e0ef), Color(0xFF42c2ff)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Energia: ${(cajuGame.currentEnergy).floor()}/${cajuGame.maxEnergy.floor()}',
                            style: const TextStyle(
                              fontFamily: 'VT323',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        },
        initialActiveOverlays: const ['energyHud'],
      ),
    );
  }
}
