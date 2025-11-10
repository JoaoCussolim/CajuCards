import 'dart:async';
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
    required this.game,
    required card_model.TroopCard cardData,
    required this.isOpponent,
    required this.laneY,
    double? attackRange,
    double? attackCooldown,
    double? moveSpeed,
  })  : currentHp = cardData.health.toDouble(),
        attackRange = attackRange ?? 140,
        attackCooldown = attackCooldown ?? 0.9,
        moveSpeed = moveSpeed ?? 80,
        super(cardData: cardData);

  final CajuPlaygroundGame game;
  final bool isOpponent;
  final double laneY;
  final double attackRange;
  final double attackCooldown;
  final double moveSpeed;
  double currentHp;
  TroopComponent? currentTarget;

  double _cooldownTimer = 0;
  bool isDying = false;

  bool get isDead => currentHp <= 0;

  Vector2 get _enemyTowerFront =>
      isOpponent ? game.playerTowerFront : game.opponentTowerFront;

  void tick(double dt, Iterable<TroopComponent> enemies) {
    if (isRemoved || isDying || isDead) {
      return;
    }

    _cooldownTimer = math.max(0, _cooldownTimer - dt);
    _refreshTarget(enemies);

    final target = currentTarget;
    if (target != null) {
      final distance = position.distanceTo(target.position);
      if (distance > attackRange * 0.85) {
        _moveTowards(target.position, dt);
      } else if (_cooldownTimer <= 0) {
        _strikeTroop(target);
      }
      return;
    }

    final towerDestination = Vector2(_enemyTowerFront.x, laneY);
    final distanceToTower = position.distanceTo(towerDestination);
    if (distanceToTower > attackRange * 0.9) {
      _moveTowards(towerDestination, dt, clampToLane: true);
      return;
    }

    if (_cooldownTimer <= 0) {
      _strikeTower();
    }
  }

  void _refreshTarget(Iterable<TroopComponent> enemies) {
    final target = currentTarget;
    final needsNewTarget =
        target == null ||
        target.isRemoved ||
        target.isDying ||
        target.isDead ||
        position.distanceTo(target.position) > attackRange;

    if (!needsNewTarget) {
      return;
    }

    currentTarget = _findClosestTarget(enemies);
  }

  void _moveTowards(Vector2 destination, double dt,
      {bool clampToLane = false}) {
    final delta = destination - position;
    if (delta.length2 == 0) {
      return;
    }

    final direction = delta.normalized();
    final maxStep = moveSpeed * dt;
    final distance = delta.length;
    final step = math.min(maxStep, distance);

    position += direction * step;

    if (clampToLane) {
      final laneDelta = laneY - position.y;
      if (laneDelta.abs() <= 1.5) {
        position.y = laneY;
      } else {
        final correction = laneDelta.sign * math.min(laneDelta.abs(), moveSpeed * 0.45 * dt);
        position.y += correction;
      }
    }
  }

  void _strikeTroop(TroopComponent target) {
    if (target.isDead || target.isDying) {
      return;
    }

    _cooldownTimer = attackCooldown;
    target.receiveDamage(cardData.damage.toDouble());
    _playAttackAnimation();
  }

  void _strikeTower() {
    _cooldownTimer = attackCooldown;
    game.applyBaseDamage(
      toOpponent: !isOpponent,
      amount: cardData.damage.toDouble(),
    );
    _playAttackAnimation();
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

  void _playAttackAnimation() {
    final swingAngle = (math.pi / 6) * (isOpponent ? -1 : 1);
    add(
      SequenceEffect([
        RotateEffect.by(
          swingAngle,
          EffectController(duration: 0.1, curve: Curves.easeOut),
        ),
        RotateEffect.by(
          -swingAngle,
          EffectController(duration: 0.12, curve: Curves.easeIn),
        ),
      ]),
    );
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
          paint: Paint()..color = Colors.white.withOpacity(0.22),
        );
}

class CajuPlaygroundGame extends FlameGame with TapCallbacks {
  CajuPlaygroundGame({this.socketService, this.isBotMode = false})
      : _simulationRunning = false;

  CajuPlaygroundGame.bot() : this(isBotMode: true);

  final SocketService? socketService;
  final bool isBotMode;

  bool _simulationRunning;
  bool _initialized = false;

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
  final ValueNotifier<double> playerHealthRatioNotifier =
      ValueNotifier<double>(1);
  final ValueNotifier<double> opponentHealthRatioNotifier =
      ValueNotifier<double>(1);
  final ValueNotifier<bool> simulationRunningNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> readinessNotifier = ValueNotifier<bool>(false);
  final int shopSize = 3;
  late final TowerComponent playerTowerComponent;
  late final TowerComponent opponentTowerComponent;
  late final Vector2 playerTowerFront;
  late final Vector2 opponentTowerFront;
  late final List<double> _laneCenters;
  final double _laneVariance = 22;

  final Map<TroopComponent, card_model.TroopCard> _creaturesInField = {};
  final Map<TroopComponent, card_model.TroopCard> _opponentTroops = {};
  List<card_model.Card> _allCards = [];
  final math.Random _random = math.Random();
  BotController? _botController;
  card_model.SpellCard? _pendingSpellCard;
  CardSprite? _pendingSpellSprite;

  String? get activeBackgroundSynergy => backgroundSynergyNotifier.value;
  bool get isSimulationRunning => _simulationRunning;
  bool get isReady => _initialized;

  double playerHealth = 100;
  double opponentHealth = 100;
  final double maxHealth = 100;

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

    _initialized = true;
    readinessNotifier.value = true;

    resetSimulation();

    if (!isBotMode) {
      startSimulation();
    }
  }

  Future<void> _buildArena() async {
    final dividerHeight = size.y * 0.82;

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

    final battlefieldSurface = RectangleComponent(
      size: Vector2(size.x * 0.86, size.y * 0.64),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF1f2338).withOpacity(0.9),
    );
    add(battlefieldSurface);

    add(
      RectangleComponent(
        size: Vector2(size.x * 0.9, size.y * 0.68),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        paint: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Colors.white.withOpacity(0.08),
      ),
    );

    final laneSpacing = size.y * 0.16;
    final laneHeight = size.y * 0.16;
    _laneCenters = [];

    for (final offset in [-1, 0, 1]) {
      final laneY = size.y / 2 + laneSpacing * offset;
      _laneCenters.add(laneY);
      final highlightColor = offset == 0
          ? const Color(0xFF8ad8ff).withOpacity(0.12)
          : const Color(0xFFf6c372).withOpacity(0.08);

      add(
        RectangleComponent(
          size: Vector2(size.x * 0.78, laneHeight),
          position: Vector2(size.x / 2, laneY),
          anchor: Anchor.center,
          paint: Paint()..color = highlightColor,
        ),
      );
    }

    add(
      ArenaDivider(
        size: Vector2(size.x * 0.012, dividerHeight),
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );

    final towerSize = Vector2(size.x * 0.1, size.y * 0.18);

    playerTowerComponent = TowerComponent(
      size: towerSize,
      position: Vector2(0, size.y / 2),
      anchor: Anchor.centerLeft,
    );
    add(playerTowerComponent);

    opponentTowerComponent = TowerComponent(
      size: towerSize,
      position: Vector2(size.x, size.y / 2),
      anchor: Anchor.centerRight,
      isOpponent: true,
    );
    add(opponentTowerComponent);

    playerTowerFront = Vector2(
      playerTowerComponent.position.x + playerTowerComponent.size.x / 2 + 36,
      playerTowerComponent.position.y,
    );
    opponentTowerFront = Vector2(
      opponentTowerComponent.position.x -
          opponentTowerComponent.size.x / 2 -
          36,
      opponentTowerComponent.position.y,
    );
  }

  Future<void> applyBackgroundBiome(String synergy) async {
    if (activeBackgroundSynergy == synergy) {
      return;
    }

    final spritePath = 'assets/images/sprites/background/$synergy.png';

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

    if (!_simulationRunning) {
      return;
    }

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
    playerHealthRatioNotifier.dispose();
    opponentHealthRatioNotifier.dispose();
    simulationRunningNotifier.dispose();
    readinessNotifier.dispose();
    super.onRemove();
  }

  void startSimulation() {
    if (!_initialized || _simulationRunning) {
      return;
    }
    _clearSpellSelection();
    _simulationRunning = true;
    simulationRunningNotifier.value = true;
    _botController?.reset();
  }

  void stopSimulation() {
    if (!_initialized || !_simulationRunning) {
      return;
    }
    _simulationRunning = false;
    simulationRunningNotifier.value = false;
  }

  void resetSimulation() {
    if (!_initialized) {
      return;
    }

    stopSimulation();
    _clearSpellSelection();

    currentEnergy = 0;
    matchTimeSeconds = 0;
    playerHealth = maxHealth;
    opponentHealth = maxHealth;
    energyText.text = 'Energia: 0/${maxEnergy.floor()}';
    matchTimerText.text = 'Tempo: 0.0s';
    energyRatioNotifier.value = 0;
    playerHealthRatioNotifier.value = 1;
    opponentHealthRatioNotifier.value = 1;
    _clearBattlefield();
    resetBackgroundBiome();
    _populateShop();
    _botController?.reset();
  }

  void applyBaseDamage({required bool toOpponent, required double amount}) {
    if (!_initialized || amount <= 0) {
      return;
    }

    if (toOpponent) {
      opponentHealth = (opponentHealth - amount).clamp(0, maxHealth);
      opponentHealthRatioNotifier.value = opponentHealth / maxHealth;
      _animateTowerHit(onOpponentSide: true);
    } else {
      playerHealth = (playerHealth - amount).clamp(0, maxHealth);
      playerHealthRatioNotifier.value = playerHealth / maxHealth;
      _animateTowerHit(onOpponentSide: false);
    }
  }

  void _animateTowerHit({required bool onOpponentSide}) {
    final tower = onOpponentSide ? opponentTowerComponent : playerTowerComponent;
    if (tower.isRemoved) {
      return;
    }

    tower.add(
      SequenceEffect([
        OpacityEffect.to(
          0.65,
          EffectController(duration: 0.06, curve: Curves.easeOut),
        ),
        OpacityEffect.to(
          1.0,
          EffectController(duration: 0.14, curve: Curves.easeIn),
        ),
      ]),
    );
  }

  void _clearBattlefield() {
    if (!_initialized) {
      return;
    }

    for (final troop in List<TroopComponent>.from(_creaturesInField.keys)) {
      troop.removeFromParent();
    }
    _creaturesInField.clear();

    for (final troop in List<TroopComponent>.from(_opponentTroops.keys)) {
      troop.removeFromParent();
    }
    _opponentTroops.clear();
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

  void spawnCreatureAndAttack(card_model.TroopCard cardData) {
    final laneY = _pickLaneY();
    final spawnPosition = _playerSpawnPoint(laneY);

    final troop = TroopComponent(
      game: this,
      cardData: cardData,
      isOpponent: false,
      laneY: laneY,
    )
      ..position = spawnPosition
      ..anchor = Anchor.center;

    _trackPlayerTroop(troop, cardData);
    add(troop);
  }

  void spawnOpponentTroop(card_model.TroopCard cardData) {
    final laneY = _pickLaneY();
    final spawnPosition = _opponentSpawnPoint(laneY);

    final troop = TroopComponent(
      game: this,
      cardData: cardData,
      isOpponent: true,
      laneY: laneY,
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

    unawaited(_animateSpell(effect, affected, card));
  }

  void prepareSpell(card_model.SpellCard card, CardSprite sprite) {
    if (_pendingSpellSprite == sprite) {
      _clearSpellSelection();
      return;
    }

    if (currentEnergy < card.chestnutCost) {
      print('Energia insuficiente para: ${card.name}');
      return;
    }

    _clearSpellSelection();
    _pendingSpellCard = card;
    _pendingSpellSprite = sprite;
    sprite.setSelected(true);
  }

  bool tryCastSelectedSpellAt(Vector2 position) {
    final pending = _pendingSpellCard;
    if (pending == null) {
      return false;
    }

    final handThreshold = size.y - cardSize.y - 24;
    if (position.y >= handThreshold) {
      return false;
    }

    if (currentEnergy < pending.chestnutCost) {
      print('Energia insuficiente para: ${pending.name}');
      return false;
    }

    currentEnergy -= pending.chestnutCost;
    castSpell(pending, targetPosition: position, byPlayer: true);
    _clearSpellSelection();

    energyText.text = 'Energia: ${currentEnergy.floor()}/${maxEnergy.floor()}';
    energyRatioNotifier.value = currentEnergy / maxEnergy;

    return true;
  }

  void _clearSpellSelection() {
    _pendingSpellSprite?.setSelected(false);
    _pendingSpellCard = null;
    _pendingSpellSprite = null;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (event.handled) {
      return;
    }

    if (tryCastSelectedSpellAt(event.localPosition)) {
      event.handled = true;
    }
  }

  double _pickLaneY() {
    if (_laneCenters.isEmpty) {
      return size.y / 2;
    }

    final baseLane = _laneCenters[_random.nextInt(_laneCenters.length)];
    final jitter = (_random.nextDouble() * 2 - 1) * _laneVariance;
    final value = (baseLane + jitter).clamp(size.y * 0.2, size.y * 0.8);
    return value.toDouble();
  }

  Vector2 _playerSpawnPoint(double laneY) {
    final offset = 18 + _random.nextDouble() * 22;
    return Vector2(playerTowerFront.x - offset, laneY);
  }

  Vector2 _opponentSpawnPoint(double laneY) {
    final offset = 18 + _random.nextDouble() * 22;
    return Vector2(opponentTowerFront.x + offset, laneY);
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

    if (playerHealth <= 0 || opponentHealth <= 0) {
      stopSimulation();
    }
  }

  Future<void> _animateSpell(SpellEffect effect, List<TroopComponent> affected,
      card_model.SpellCard card) async {
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

    void addCirclePulse() {
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

    Sprite? sprite;
    final spritePath = 'assets/images/sprites/${card.spritePath}';
    try {
      sprite = await loadSprite(spritePath);
    } catch (error) {
      print('Não foi possível carregar o sprite do feitiço ${card.name}');
      print(error);
    }

    if (sprite == null) {
      addCirclePulse();
      return;
    }

    final dropStart = Vector2(effect.center.x, effect.center.y - effect.radius * 2.2);
    final dropComponent = SpriteComponent(
      sprite: sprite,
      size: Vector2.all(effect.radius * 1.8),
      anchor: Anchor.center,
      position: dropStart,
    )
      ..priority = 60
      ..opacity = 0.0;

    add(dropComponent);

    dropComponent.add(
      SequenceEffect([
        OpacityEffect.to(
          1.0,
          EffectController(duration: 0.05, curve: Curves.easeIn),
        ),
        MoveEffect.to(
          effect.center,
          EffectController(duration: 0.32, curve: Curves.easeIn),
        ),
      ]),
    );

    Future.delayed(const Duration(milliseconds: 370), () {
      addCirclePulse();

      if (dropComponent.isRemoved) {
        return;
      }

      dropComponent.add(
        SequenceEffect([
          ScaleEffect.to(
            Vector2.all(1.15),
            EffectController(duration: 0.08, curve: Curves.easeOut),
          ),
          ScaleEffect.to(
            Vector2.all(0.7),
            EffectController(duration: 0.12, curve: Curves.easeIn),
          ),
          OpacityEffect.to(
            0.0,
            EffectController(duration: 0.18, curve: Curves.easeOut),
          ),
          RemoveEffect(),
        ]),
      );
    });
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
    if (!game._simulationRunning) {
      return;
    }

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

  void reset() {
    _decisionTimer = 0;
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
        game.spawnOpponentTroop(card);
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
