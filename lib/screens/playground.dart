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

class ArenaDivider extends RectangleComponent {
  ArenaDivider({
    required Vector2 size,
    required Vector2 position,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.white.withOpacity(0.35),
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
  late final TextComponent matchTimerText;
  double matchTimeSeconds = 0;
  final ValueNotifier<double> energyRatioNotifier = ValueNotifier(0);
  final ValueNotifier<List<card_model.Card>> shopCardsNotifier =
      ValueNotifier<List<card_model.Card>>([]);
  final int shopSize = 3;
  Enemy? enemy;
  List<card_model.Card> _allCards = [];

  @override
  Color backgroundColor() => const Color(0xFF2a2e42);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await _buildArena();

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

    matchTimerText = TextComponent(
      text: 'Tempo: 0.0s',
      textRenderer: textStyle,
      position: Vector2(size.x / 2, size.y * 0.1),
      anchor: Anchor.topCenter,
    );
    add(matchTimerText);

    enemy = Enemy()
      ..position =
          Vector2(size.x / 2, size.y * 0.25)
      ..anchor = Anchor.center;
    add(enemy!);

    final cardService = CardService(ApiClient());

    try {
      print("Buscando cartas...");
      _allCards = await cardService.getAllCards();
      print("Recebidas ${_allCards.length} cartas.");

      if (_allCards.isEmpty) {
        print("Nenhuma carta encontrada na API.");
        return;
      }

      _dealHandCards();
      _populateShop();
    } catch (e, stackTrace) {
      print("--- ERRO AO CARREGAR CARTAS DA API ---");
      print(e);
      print(stackTrace);
    }
  }

  Future<void> _buildArena() async {
    final dividerHeight = size.y * 0.9;

    final groundSprite = await Sprite.load('assets/images/WoodBasic.png');

    add(SpriteComponent(
      sprite: groundSprite,
      size: Vector2(size.x / 2, size.y),
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    ));

    add(SpriteComponent(
      sprite: groundSprite,
      size: Vector2(size.x / 2, size.y),
      position: Vector2(size.x, 0),
      anchor: Anchor.topRight,
    ));

    add(ArenaDivider(
      size: Vector2(size.x * 0.01, dividerHeight),
      position: Vector2(size.x / 2, size.y / 2),
    ));

    final towerSize = Vector2(size.x * 0.1, size.y * 0.18);

    add(TowerComponent(
      size: towerSize,
      position: Vector2(0, size.y / 2),
      anchor: Anchor.centerLeft,
    ));

    add(TowerComponent(
      size: towerSize,
      position: Vector2(size.x, size.y / 2),
      anchor: Anchor.centerRight,
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
    matchTimeSeconds += dt;
    matchTimerText.text = 'Tempo: ${matchTimeSeconds.toStringAsFixed(1)}s';
    energyText.text = 'Energia: ${currentEnergy.floor()}/${maxEnergy.floor()}';
    energyRatioNotifier.value = currentEnergy / maxEnergy;
  }

  @override
  void onRemove() {
    energyRatioNotifier.dispose();
    shopCardsNotifier.dispose();
    super.onRemove();
  }

  void _dealHandCards() {
    final handCount = math.min(5, _allCards.length);
    final handCards = _allCards.take(handCount).toList();

    for (var i = 0; i < handCards.length; i++) {
      final cardData = handCards[i];
      final cardSprite = CardSprite(
        card: cardData,
        game: this,
      )
        ..anchor = Anchor.bottomLeft
        ..position = Vector2(
          20 + i * (cardSize.x + 12),
          size.y - 20,
        );

      add(cardSprite);
    }
  }

  void _populateShop() {
    if (_allCards.isEmpty) {
      return;
    }

    _allCards.shuffle();
    final selection = _allCards.take(math.min(shopSize, _allCards.length)).toList();
    shopCardsNotifier.value = selection;
  }

  void rerollShop() {
    if (currentEnergy < 1) {
      return;
    }

    currentEnergy -= 1;
    _populateShop();
    energyText.text = 'Energia: ${currentEnergy.floor()}/${maxEnergy.floor()}';
    energyRatioNotifier.value = currentEnergy / maxEnergy;
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
          'shopOverlay': (context, game) {
            final cajuGame = game as CajuPlaygroundGame;
            return Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Loja',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'VT323',
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<List<card_model.Card>>(
                            valueListenable: cajuGame.shopCardsNotifier,
                            builder: (context, cards, _) {
                              if (cards.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  for (final card in cards)
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              card.name,
                                              style: const TextStyle(
                                                fontFamily: 'VT323',
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${card.chestnutCost}⚡',
                                            style: const TextStyle(
                                              fontFamily: 'VT323',
                                              fontSize: 18,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<double>(
                            valueListenable: cajuGame.energyRatioNotifier,
                            builder: (context, _, __) {
                              final canReroll = cajuGame.currentEnergy >= 1;
                              return ElevatedButton(
                                onPressed: canReroll
                                    ? () {
                                        cajuGame.rerollShop();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF42c2ff),
                                  disabledBackgroundColor:
                                      Colors.blueGrey.shade700,
                                ),
                                child: const Text(
                                  'Reroll (1 energia)',
                                  style: TextStyle(
                                    fontFamily: 'VT323',
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        },
        initialActiveOverlays: const ['energyHud', 'shopOverlay'],
      ),
    );
  }
}
