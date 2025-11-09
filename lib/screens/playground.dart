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
  Enemy? enemy;
  final Map<CreatureSprite, String> _creaturesInField = {};
  String? activeBackgroundSynergy;

  Map<CreatureSprite, String> get creaturesInField =>
      Map.unmodifiable(_creaturesInField);

  Set<String> get activeSynergies => _creaturesInField.values.toSet();

  bool canSummonCreatureWithSynergy(String synergy) {
    final currentSynergies = activeSynergies;

    if (currentSynergies.contains(synergy)) {
      return true;
    }

    if (activeBackgroundSynergy != null &&
        activeBackgroundSynergy == synergy) {
      return true;
    }

    return currentSynergies.length < 4;
  }

  @override
  Color backgroundColor() => const Color(0xFF2a2e42);

  @override
  Future<void> onLoad() async {
    super.onLoad();

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
  }

  void spawnCreatureAndAttack(card_model.Card cardData) {
    if (enemy == null) return;

    final creature = CreatureSprite(cardData: cardData)
      ..position =
          size /
          2
      ..anchor = Anchor.center;

    _trackCreature(creature, cardData.synergy);
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

  void _trackCreature(CreatureSprite creature, String synergy) {
    _creaturesInField[creature] = synergy;
    creature.onRemovedCallback = () {
      _creaturesInField.remove(creature);
    };
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
      body: GameWidget(game: _game),
    );
  }
}
