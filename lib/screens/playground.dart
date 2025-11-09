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

class SpellEffect {
  final Vector2 center;
  final double radius;
  final int damage;

  const SpellEffect({
    required this.center,
    required this.radius,
    required this.damage,
  });

  List<TroopComponent> apply(Iterable<TroopComponent> candidates) {
    final affected = <TroopComponent>[];
    for (final troop in candidates) {
      if (troop.isRemoved || troop.isDying || troop.isDead) {
        continue;
      }
      if (troop.position.distanceTo(center) <= radius) {
        troop.receiveDamage(damage.toDouble());
        affected.add(troop);
      }
    }
    return affected;
  }
}

class TroopComponent extends CreatureSprite {
  TroopComponent({
    required card_model.TroopCard cardData,
    required this.isOpponent,
    double? attackRange,
    double? attackCooldown,
  })  : currentHp = cardData.health.toDouble(),
        attackRange = attackRange ?? 160,
        attackCooldown = attackCooldown ?? 1.0,
        super(cardData: cardData);

  final bool isOpponent;
  final double attackRange;
  final double attackCooldown;
  double currentHp;
  TroopComponent? currentTarget;

  double _cooldownTimer = 0;
  bool isDying = false;

  bool get isDead => currentHp <= 0;

  void tick(double dt, Iterable<TroopComponent> enemies) {
    if (isRemoved || isDying || isDead) {
      return;
    }

    _cooldownTimer = math.max(0, _cooldownTimer - dt);

    if (currentTarget == null ||
        currentTarget!.isRemoved ||
        currentTarget!.isDying ||
        currentTarget!.isDead ||
        position.distanceTo(currentTarget!.position) > attackRange) {
      currentTarget = _findClosestTarget(enemies);
    }

    if (currentTarget == null) {
      return;
    }

    if (_cooldownTimer <= 0 &&
        position.distanceTo(currentTarget!.position) <= attackRange) {
      performAttack();
    }
  }

  void performAttack() {
    final target = currentTarget;
    if (target == null || target.isDead || target.isDying) {
      return;
    }

    _cooldownTimer = attackCooldown;
    target.receiveDamage(cardData.damage.toDouble());
    _playAttackAnimation(target);
  }

  void receiveDamage(double amount) {
    if (isDying || isRemoved) {
      return;
    }

    currentHp -= amount;
    if (currentHp <= 0) {
      currentHp = 0;
      _handleDeath();
    } else {
      _playHitAnimation();
    }
  }

  TroopComponent? _findClosestTarget(Iterable<TroopComponent> enemies) {
    TroopComponent? closest;
    var closestDistance = double.infinity;
    for (final candidate in enemies) {
      if (candidate == this ||
          candidate.isRemoved ||
          candidate.isDying ||
          candidate.isDead) {
        continue;
      }
      final distance = position.distanceTo(candidate.position);
      if (distance < closestDistance) {
        closest = candidate;
        closestDistance = distance;
      }
    }
    return closest;
  }

  void _playAttackAnimation(TroopComponent target) {
    final direction = target.position - position;
    if (direction.length2 == 0) {
      return;
    }
    direction.normalize();
    final offset = direction.scaled(14);

    final attackSequence = SequenceEffect([
      MoveEffect.by(
        offset,
        EffectController(duration: 0.08),
      ),
      MoveEffect.by(
        -offset,
        EffectController(duration: 0.12),
      ),
    ]);

    add(attackSequence);
  }

  void _playHitAnimation() {
    add(
      SequenceEffect([
        OpacityEffect.to(
          0.4,
          EffectController(duration: 0.05),
        ),
        OpacityEffect.to(
          1.0,
          EffectController(duration: 0.1),
        ),
      ]),
    );
  }

  void _handleDeath() {
    if (isDying) {
      return;
    }
    isDying = true;
    currentTarget = null;

    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.2, curve: Curves.easeIn),
        ),
        RemoveEffect(),
      ]),
    );
  }
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

class ArenaDivider extends RectangleComponent {
  ArenaDivider({required Vector2 size, required Vector2 position})
      : super(
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
  late final SpriteComponent backgroundLayer;
  late final Sprite _defaultPlayerBackgroundSprite;
  final ValueNotifier<double> energyRatioNotifier = ValueNotifier(0);
  final ValueNotifier<List<card_model.Card>> shopCardsNotifier =
      ValueNotifier<List<card_model.Card>>([]);
  final ValueNotifier<String?> backgroundSynergyNotifier =
      ValueNotifier<String?>(null);
  final int shopSize = 3;
  Enemy? enemy;

  final Map<TroopComponent, card_model.TroopCard> _creaturesInField = {};
  final Map<TroopComponent, card_model.TroopCard> _opponentTroops = {};
  List<card_model.Card> _allCards = [];
  final math.Random _random = math.Random();
  BotController? _botController;

  String? get activeBackgroundSynergy => backgroundSynergyNotifier.value;

  Map<TroopComponent, card_model.TroopCard> get creaturesInField =>
      Map.unmodifiable(_creaturesInField);

  Set<String> get activeSynergies =>
      _creaturesInField.values.map((card) => card.synergy).toSet();

  bool canSummonCreatureWithSynergy(String synergy) {
    final currentSynergies = activeSynergies;

    final backgroundSynergy = backgroundSynergyNotifier.value;

    if (backgroundSynergy != null) {
      return backgroundSynergy == synergy;
    }

    if (currentSynergies.contains(synergy)) {
      return true;
    }

    return currentSynergies.length < 4;
  }

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
      ..position = Vector2(size.x / 2, size.y * 0.25)
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

    if (_allCards.isNotEmpty) {
      _botController = BotController(game: this);
    }
  }

  Future<void> _buildArena() async {
    final dividerHeight = size.y * 0.9;

    final groundSprite = await Sprite.load('assets/images/WoodBasic.png');

    _defaultPlayerBackgroundSprite = groundSprite;
    backgroundLayer = SpriteComponent(
      sprite: _defaultPlayerBackgroundSprite,
      size: Vector2(size.x / 2, size.y),
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    );

    add(backgroundLayer);

    add(
      SpriteComponent(
        sprite: groundSprite,
        size: Vector2(size.x / 2, size.y),
        position: Vector2(size.x, 0),
        anchor: Anchor.topRight,
      ),
    );

    add(
      ArenaDivider(
        size: Vector2(size.x * 0.01, dividerHeight),
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );

    final towerSize = Vector2(size.x * 0.1, size.y * 0.18);

    add(
      TowerComponent(
        size: towerSize,
        position: Vector2(0, size.y / 2),
        anchor: Anchor.centerLeft,
      ),
    );

    add(
      TowerComponent(
        size: towerSize,
        position: Vector2(size.x, size.y / 2),
        anchor: Anchor.centerRight,
        isOpponent: true,
      ),
    );
  }

  Future<void> applyBackgroundBiome(String synergy) async {
    if (activeBackgroundSynergy == synergy) {
      return;
    }

    final spritePath = 'images/sprites/background/$synergy.png';

    try {
      final newSprite = await loadSprite(spritePath);
      backgroundLayer.sprite = newSprite;
      backgroundSynergyNotifier.value = synergy;
    } catch (error, stackTrace) {
      print('Não foi possível carregar o bioma "$synergy" ($spritePath).');
      print(error);
      print(stackTrace);
    }
  }

  void resetBackgroundBiome() {
    backgroundLayer.sprite = _defaultPlayerBackgroundSprite;
    backgroundSynergyNotifier.value = null;
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

    _updateBattlefield(dt);
    _botController?.update(dt);
  }

  @override
  void onRemove() {
    energyRatioNotifier.dispose();
    shopCardsNotifier.dispose();
    backgroundSynergyNotifier.dispose();
    super.onRemove();
  }

  void _dealHandCards() {
    final handCount = math.min(5, _allCards.length);
    final handCards = _allCards.take(handCount).toList();

    for (var i = 0; i < handCards.length; i++) {
      final cardData = handCards[i];
      final cardSprite = CardSprite(card: cardData, game: this)
        ..anchor = Anchor.bottomLeft
        ..position = Vector2(20 + i * (cardSize.x + 12), size.y - 20);

      add(cardSprite);
    }
  }

  void _populateShop() {
    if (_allCards.isEmpty) {
      return;
    }

    _allCards.shuffle();
    final selection =
        _allCards.take(math.min(shopSize, _allCards.length)).toList();
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

  void spawnCreatureAndAttack(card_model.TroopCard cardData,
      {Vector2? position}) {
    final spawnPosition = position ?? _randomPlayerSpawnPosition();

    final troop = TroopComponent(
      cardData: cardData,
      isOpponent: false,
    )
      ..position = spawnPosition
      ..anchor = Anchor.center;

    _trackPlayerTroop(troop, cardData);
    add(troop);
  }

  void spawnOpponentTroop(card_model.TroopCard cardData, {Vector2? position}) {
    final spawnPosition = position ?? _randomOpponentSpawnPosition();
    final troop = TroopComponent(
      cardData: cardData,
      isOpponent: true,
    )
      ..position = spawnPosition
      ..anchor = Anchor.center
      ..flipHorizontally = true;

    _trackOpponentTroop(troop, cardData);
    add(troop);
  }

  void _trackPlayerTroop(TroopComponent troop, card_model.TroopCard card) {
    _creaturesInField[troop] = card;
    troop.onRemovedCallback = () {
      _creaturesInField.remove(troop);
    };
  }

  void _trackOpponentTroop(TroopComponent troop, card_model.TroopCard card) {
    _opponentTroops[troop] = card;
    troop.onRemovedCallback = () {
      _opponentTroops.remove(troop);
    };
  }

  void castSpell(card_model.SpellCard card,
      {Vector2? targetPosition, bool byPlayer = true}) {
    final radius = card.radius ?? 120;
    final damage = card.damage ?? 25;

    final defaultX = byPlayer ? size.x * 0.75 : size.x * 0.25;
    final center = targetPosition ?? Vector2(defaultX, size.y / 2);

    final effect = SpellEffect(
      center: center,
      radius: radius.toDouble(),
      damage: damage,
    );

    final targets = byPlayer ? _opponentTroops.keys : _creaturesInField.keys;
    final affected = effect.apply(targets);

    _animateSpell(effect, affected);
  }

  Vector2 _randomPlayerSpawnPosition() {
    final horizontal = size.x * (0.15 + _random.nextDouble() * 0.2);
    final vertical = size.y * (0.25 + _random.nextDouble() * 0.5);
    return Vector2(horizontal, vertical);
  }

  Vector2 _randomOpponentSpawnPosition() {
    final horizontal = size.x * (0.65 + _random.nextDouble() * 0.2);
    final vertical = size.y * (0.25 + _random.nextDouble() * 0.5);
    return Vector2(horizontal, vertical);
  }

  void _updateBattlefield(double dt) {
    final playerTroops = List<TroopComponent>.from(_creaturesInField.keys);
    final opponentTroops = List<TroopComponent>.from(_opponentTroops.keys);

    for (final troop in playerTroops) {
      troop.tick(dt, opponentTroops);
    }

    for (final troop in opponentTroops) {
      troop.tick(dt, playerTroops);
    }
  }

  void _animateSpell(SpellEffect effect, List<TroopComponent> affected) {
    final color = affected.isEmpty
        ? Colors.blueAccent.withOpacity(0.3)
        : Colors.deepOrangeAccent.withOpacity(0.4);

    final spellCircle = CircleComponent(
      radius: effect.radius,
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    )
      ..anchor = Anchor.center
      ..position = effect.center;

    add(spellCircle);

    spellCircle.add(
      SequenceEffect([
        OpacityEffect.to(
          0.0,
          EffectController(duration: 0.4, curve: Curves.easeOut),
        ),
        RemoveEffect(),
      ]),
    );
  }
}

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class BotController {
  BotController({
    required this.game,
    this.minDecisionInterval = 3.0,
    this.maxDecisionInterval = 6.0,
  }) : _decisionTimer = 0 {
    _resetTimer();
  }

  final CajuPlaygroundGame game;
  final double minDecisionInterval;
  final double maxDecisionInterval;
  double _decisionTimer;
  final math.Random _random = math.Random();

  void update(double dt) {
    if (game._allCards.isEmpty) {
      return;
    }

    _decisionTimer -= dt;
    if (_decisionTimer > 0) {
      return;
    }

    _playRandomCard();
    _resetTimer();
  }

  void _resetTimer() {
    final intervalRange = maxDecisionInterval - minDecisionInterval;
    _decisionTimer = minDecisionInterval + _random.nextDouble() * intervalRange;
  }

  void _playRandomCard() {
    final pool = game.shopCardsNotifier.value.isNotEmpty
        ? game.shopCardsNotifier.value
        : game._allCards;

    if (pool.isEmpty) {
      return;
    }

    var attempts = 0;
    while (attempts < 5) {
      final card = pool[_random.nextInt(pool.length)];

      if (card is card_model.TroopCard) {
        final position = Vector2(
          game.size.x * (0.65 + _random.nextDouble() * 0.25),
          game.size.y * (0.25 + _random.nextDouble() * 0.5),
        );
        game.spawnOpponentTroop(card, position: position);
        return;
      }

      if (card is card_model.SpellCard) {
        final position = Vector2(
          game.size.x * (0.25 + _random.nextDouble() * 0.4),
          game.size.y * (0.25 + _random.nextDouble() * 0.5),
        );
        game.castSpell(card, targetPosition: position, byPlayer: false);
        return;
      }

      attempts += 1;
    }
  }
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
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
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
                                    colors: [
                                      Color(0xFF88e0ef),
                                      Color(0xFF42c2ff),
                                    ],
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
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
