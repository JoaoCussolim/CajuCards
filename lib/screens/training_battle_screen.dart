import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'playground.dart';

class TrainingBattleScreen extends StatefulWidget {
  const TrainingBattleScreen({super.key});

  @override
  State<TrainingBattleScreen> createState() => _TrainingBattleScreenState();
}

class _TrainingBattleScreenState extends State<TrainingBattleScreen> {
  late final CajuPlaygroundGame _game;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _game = CajuPlaygroundGame.bot();
    _game.readinessNotifier.addListener(_handleReadinessChange);
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

  void _restartSimulation() {
    if (!_game.isReady) {
      return;
    }
    _game.resetSimulation();
    _game.startSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/WoodBasic.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _TrainingHeader(onExit: () => Navigator.pop(context)),
                  const SizedBox(height: 16),
                  _TrainingHud(game: _game),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Stack(
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
                                  color: Colors.black54,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(color: Colors.white),
                                      SizedBox(height: 16),
                                      Text(
                                        'Carregando treino local...',
                                        style: TextStyle(
                                          fontFamily: 'VT323',
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _game.readinessNotifier,
                    builder: (context, ready, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _game.simulationRunningNotifier,
                        builder: (context, running, __) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _TrainingActionButton(
                                label: running ? 'Pausar' : 'Retomar',
                                onPressed: ready
                                    ? (running ? _game.stopSimulation : _game.startSimulation)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              _TrainingActionButton(
                                label: 'Reiniciar',
                                onPressed: ready ? _restartSimulation : null,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingHeader extends StatelessWidget {
  const _TrainingHeader({required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BackButton(color: Colors.white, onPressed: onExit),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Treino PvE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _TrainingHud extends StatelessWidget {
  const _TrainingHud({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: game.playerHealthRatioNotifier,
                builder: (context, ratio, _) {
                  final clamped = ratio.clamp(0.0, 1.0);
                  final life = game.playerHealth.round();
                  return _TrainingStatGauge(
                    label: 'Sua Vida',
                    ratio: clamped,
                    valueLabel: '$life/${game.maxHealth.round()}',
                    foreground: const Color(0xFF6fd08b),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: game.opponentHealthRatioNotifier,
                builder: (context, ratio, _) {
                  final clamped = ratio.clamp(0.0, 1.0);
                  final life = game.opponentHealth.round();
                  return _TrainingStatGauge(
                    label: 'Vida do Bot',
                    ratio: clamped,
                    valueLabel: '$life/${game.maxHealth.round()}',
                    foreground: const Color(0xFFe66464),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<double>(
          valueListenable: game.energyRatioNotifier,
          builder: (context, ratio, _) {
            final energy = game.currentEnergy.floor();
            return _TrainingStatGauge(
              label: 'Energia',
              ratio: ratio.clamp(0.0, 1.0),
              valueLabel: '$energy/${game.maxEnergy.floor()}',
              foreground: const Color(0xFF42c2ff),
            );
          },
        ),
      ],
    );
  }
}

class _TrainingStatGauge extends StatelessWidget {
  const _TrainingStatGauge({
    required this.label,
    required this.ratio,
    required this.valueLabel,
    required this.foreground,
  });

  final String label;
  final double ratio;
  final String valueLabel;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [foreground.withOpacity(0.9), foreground],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valueLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TrainingActionButton extends StatelessWidget {
  const _TrainingActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 24,
        ),
      ),
    );
  }
}
