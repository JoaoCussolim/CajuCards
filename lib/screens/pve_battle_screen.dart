import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'playground.dart';

class PveBattleScreen extends StatefulWidget {
  const PveBattleScreen({super.key});

  @override
  State<PveBattleScreen> createState() => _PveBattleScreenState();
}

class _PveBattleScreenState extends State<PveBattleScreen> {
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
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
                                        'Carregando batalha PvE...',
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
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: _BattleScoreboard(game: _game),
                ),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: _EnergyBar(game: _game),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleScoreboard extends StatelessWidget {
  const _BattleScoreboard({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: _HealthGauge(
              label: 'Você',
              ratioListenable: game.playerHealthRatioNotifier,
              currentHealth: () => game.playerHealth,
              maxHealth: () => game.maxHealth,
              foreground: const LinearGradient(
                colors: [
                  Color(0xFF81f499),
                  Color(0xFF3ecf7a),
                ],
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HealthGauge(
              label: 'Bot',
              ratioListenable: game.opponentHealthRatioNotifier,
              currentHealth: () => game.opponentHealth,
              maxHealth: () => game.maxHealth,
              foreground: const LinearGradient(
                colors: [
                  Color(0xFFf28482),
                  Color(0xFFd90429),
                ],
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthGauge extends StatelessWidget {
  const _HealthGauge({
    required this.label,
    required this.ratioListenable,
    required this.currentHealth,
    required this.maxHealth,
    required this.foreground,
    required this.alignment,
  });

  final String label;
  final ValueListenable<double> ratioListenable;
  final double Function() currentHealth;
  final double Function() maxHealth;
  final LinearGradient foreground;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final alignRight = alignment == Alignment.centerRight;
    return ValueListenableBuilder<double>(
      valueListenable: ratioListenable,
      builder: (context, ratio, _) {
        final clamped = ratio.clamp(0.0, 1.0);
        final current = currentHealth().clamp(0, maxHealth()).round();
        final maxValue = maxHealth().round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment:
                alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Align(
                  alignment: alignment,
                  child: FractionallySizedBox(
                    alignment: alignment,
                    widthFactor: clamped,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: foreground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vida: $current/$maxValue',
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EnergyBar extends StatelessWidget {
  const _EnergyBar({required this.game});

  final CajuPlaygroundGame game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: ValueListenableBuilder<double>(
            valueListenable: game.energyRatioNotifier,
            builder: (context, ratio, _) {
              final clamped = ratio.clamp(0.0, 1.0);
              final current = game.currentEnergy.floor();
              final maxEnergy = game.maxEnergy.floor();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: clamped,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF58cced),
                              Color(0xFF149ddd),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Energia: $current/$maxEnergy',
                    style: const TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 22,
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
  }
}
