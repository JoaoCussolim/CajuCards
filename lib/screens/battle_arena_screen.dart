import 'package:cajucards/api/services/socket_service.dart';
import 'package:cajucards/components/card_sprite.dart';
import 'package:cajucards/models/card.dart' as card_model;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'playground.dart';

class BattleArenaScreen extends StatefulWidget {
  const BattleArenaScreen._({
    required CajuPlaygroundGame Function() gameBuilder,
    super.key,
  }) : _gameBuilder = gameBuilder;

  factory BattleArenaScreen.bot({Key? key}) {
    return BattleArenaScreen._(
      gameBuilder: CajuPlaygroundGame.bot,
      key: key,
    );
  }

  factory BattleArenaScreen.online({
    Key? key,
    required SocketService socketService,
  }) {
    return BattleArenaScreen._(
      gameBuilder: () => CajuPlaygroundGame(socketService: socketService),
      key: key,
    );
  }

  final CajuPlaygroundGame Function() _gameBuilder;

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen> {
  late final CajuPlaygroundGame _game;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _game = widget._gameBuilder();
    _game.readinessNotifier.addListener(_handleReadinessChange);
    _handleReadinessChange();
  }

  void _handleReadinessChange() {
    if (_game.readinessNotifier.value && !_started) {
      _started = true;
      _game.startSimulation();
    }
  }

  @override
  void dispose() {
    _game.readinessNotifier.removeListener(_handleReadinessChange);
    _game.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<bool>(
            valueListenable: _game.readinessNotifier,
            builder: (context, ready, _) {
              if (ready) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Carregando batalha...',
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _BackButton(onPressed: () => Navigator.pop(context)),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _BattleHud(game: _game),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _EnergyMeter(game: _game),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _ShopPanel(game: _game),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _BattleHud extends StatelessWidget {
  const _BattleHud({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        game.playerHealthRatioNotifier,
        game.opponentHealthRatioNotifier,
        game.matchTimeNotifier,
      ]),
      builder: (context, _) {
        final totalSeconds = game.matchTimeNotifier.value.floor();
        final minutes = totalSeconds ~/ 60;
        final seconds = totalSeconds % 60;
        final timerText =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerText,
                    style: const TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HealthMeter(
                          label: 'Você',
                          alignment: Alignment.centerLeft,
                          ratio: game.playerHealthRatioNotifier.value,
                          current: game.playerHealth,
                          max: game.maxHealth,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF81f499), Color(0xFF3ecf7a)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _HealthMeter(
                          label: 'Oponente',
                          alignment: Alignment.centerRight,
                          ratio: game.opponentHealthRatioNotifier.value,
                          current: game.opponentHealth,
                          max: game.maxHealth,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf28482), Color(0xFFd90429)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HealthMeter extends StatelessWidget {
  const _HealthMeter({
    required this.label,
    required this.alignment,
    required this.ratio,
    required this.current,
    required this.max,
    required this.gradient,
  });

  final String label;
  final Alignment alignment;
  final double ratio;
  final double current;
  final double max;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignment == Alignment.centerLeft
        ? TextAlign.left
        : TextAlign.right;
    final clampRatio = ratio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: alignment == Alignment.centerLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
            ),
            child: FractionallySizedBox(
              alignment: alignment,
              widthFactor: clampRatio,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${current.round()}/${max.round()}',
          textAlign: textAlign,
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _EnergyMeter extends StatelessWidget {
  const _EnergyMeter({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    final cardsWidth = cardSize.x * 5 + 4 * 12;

    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: AnimatedBuilder(
        animation: game.energyRatioNotifier,
        builder: (context, _) {
          final ratio = game.energyRatioNotifier.value.clamp(0.0, 1.0);
          final energyText =
              '${game.currentEnergy.floor()}/${game.maxEnergy.floor()}';

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: cardsWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 14,
                    color: Colors.white.withOpacity(0.25),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ratio,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF88e0ef), Color(0xFF42c2ff)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Energia: $energyText',
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
    );
  }
}

class _ShopPanel extends StatelessWidget {
  const _ShopPanel({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, bottom: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 12),
                ValueListenableBuilder<List<card_model.Card>>(
                  valueListenable: game.shopCardsNotifier,
                  builder: (context, cards, _) {
                    if (cards.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final card in cards)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
                AnimatedBuilder(
                  animation: game.energyRatioNotifier,
                  builder: (context, _) {
                    final canReroll = game.currentEnergy >= 1;
                    return ElevatedButton(
                      onPressed: canReroll ? game.rerollShop : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42c2ff),
                        disabledBackgroundColor: Colors.blueGrey.shade700,
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
    );
  }
}
