import 'package:cajucards/screens/matchmaking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:cajucards/models/player.dart';
import 'package:flame/game.dart';
import 'package:cajucards/screens/playground.dart';
import 'shop_screen.dart';
import 'history_screen.dart';
import 'package:cajucards/api/services/socket_service.dart';

enum BattleMode { pvp, training }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final CajuPlaygroundGame _trainingGame;
  BattleMode _selectedMode = BattleMode.pvp;

  @override
  void initState() {
    super.initState();
    _trainingGame = CajuPlaygroundGame.bot();
  }

  void _onModeSelected(BattleMode mode) {
    if (_selectedMode == mode) {
      return;
    }

    setState(() {
      _selectedMode = mode;
    });

    if (mode == BattleMode.training) {
      _trainingGame.resetSimulation();
    } else {
      _trainingGame.stopSimulation();
    }
  }

  void _startMatchmaking() {
    final socketService = context.read<SocketService>();
    socketService.findMatch();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MatchmakingScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _startTraining() {
    _trainingGame.resetSimulation();
    _trainingGame.startSimulation();
  }

  void _stopTraining() {
    _trainingGame.stopSimulation();
  }

  void _resetTraining() {
    _trainingGame.resetSimulation();
  }

  @override
  void dispose() {
    _trainingGame.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/WoodBasic.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
              if (playerProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (playerProvider.error != null)
                Center(
                  child: Text(
                    playerProvider.error!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'VT323',
                      fontSize: 24,
                    ),
                  ),
                )
              else if (playerProvider.player != null)
                _buildMainContent(context, playerProvider.player!)
              else
                const Center(
                  child: Text(
                    'Nenhum dado encontrado.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, Player player) {
    const double tamanhoCastanha = 240.0;
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 140,
            left: 40,
            child: Image.asset(
              'assets/images/Castanha1Cima.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            top: 140,
            right: 40,
            child: Image.asset(
              'assets/images/Castanha2Cima.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            child: Image.asset(
              'assets/images/Castanha1Baixo.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 120,
            right: 40,
            child: Image.asset(
              'assets/images/Castanha2Baixo.png',
              width: tamanhoCastanha,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 24.0,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _TopBar(
                        playerName: player.username,
                        coins: player.cashewCoins,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Image.asset('assets/images/Gear.png', width: 120),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ModeSelector(
                  selectedMode: _selectedMode,
                  onSelected: _onModeSelected,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedMode == BattleMode.pvp
                        ? _PvpPanel(
                            key: const ValueKey('pvp-mode'),
                            onStart: _startMatchmaking,
                          )
                        : _TrainingPanel(
                            key: const ValueKey('training-mode'),
                            game: _trainingGame,
                            onStart: _startTraining,
                            onStop: _stopTraining,
                            onReset: _resetTraining,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const _BottomNavBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String playerName;
  final int coins;

  const _TopBar({required this.playerName, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          height: 160,
          padding: const EdgeInsets.fromLTRB(50, 15, 60, 15),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/userContainer.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Row(
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 64,
                  color: Color(0xFF4B2D18),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Image.asset('assets/images/cajucoin.png', width: 110),
              ),
              const SizedBox(width: 15),
              Text(
                coins.toString(),
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 64,
                  color: Color(0xFF4B2D18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onSelected,
  });

  final BattleMode selectedMode;
  final ValueChanged<BattleMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        children: [
          _ModeSelectorButton(
            label: 'PvP Online',
            isSelected: selectedMode == BattleMode.pvp,
            onTap: () => onSelected(BattleMode.pvp),
          ),
          _ModeSelectorButton(
            label: 'Treino PvE',
            isSelected: selectedMode == BattleMode.training,
            onTap: () => onSelected(BattleMode.training),
          ),
        ],
      ),
    );
  }
}

class _ModeSelectorButton extends StatelessWidget {
  const _ModeSelectorButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFFF98B25).withOpacity(0.85)
        : Colors.transparent;
    final textColor = isSelected ? const Color(0xFF4B2D18) : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 26,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _PvpPanel extends StatelessWidget {
  const _PvpPanel({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Encontre um oponente online para batalhar em tempo real!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'VT323',
            fontSize: 26,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: onStart,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/images/buttonBattle.png', width: 520),
              const Text(
                'Buscar Partida PvP',
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 40,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrainingPanel extends StatelessWidget {
  const _TrainingPanel({
    super.key,
    required this.game,
    required this.onStart,
    required this.onStop,
    required this.onReset,
  });

  final CajuPlaygroundGame game;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TrainingHud(game: game),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                border: Border.all(color: Colors.white24),
              ),
              child: GameWidget(game: game),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<bool>(
          valueListenable: game.readinessNotifier,
          builder: (context, ready, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: game.simulationRunningNotifier,
              builder: (context, running, __) {
                final buttonLabel = running ? 'Encerrar Treino' : 'Iniciar Treino';
                final action = running ? onStop : onStart;
                final displayLabel = ready ? buttonLabel : 'Carregando Treino';
                return Column(
                  children: [
                    GestureDetector(
                      onTap: ready ? action : null,
                      child: Opacity(
                        opacity: ready ? 1 : 0.6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/buttonBattle.png', width: 420),
                            Text(
                              displayLabel,
                              style: const TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 38,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!ready) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Preparando cartas e arena local...',
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 22,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (running && ready) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          onReset();
                          onStart();
                        },
                        child: const Text(
                          'Reiniciar Simulação',
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
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
                  return _GaugeBar(
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
                valueListenable: game.energyRatioNotifier,
                builder: (context, ratio, _) {
                  final clamped = ratio.clamp(0.0, 1.0);
                  final energy = game.currentEnergy.floor();
                  return _GaugeBar(
                    label: 'Energia',
                    ratio: clamped,
                    valueLabel: '$energy/${game.maxEnergy.floor()}',
                    foreground: const Color(0xFF42c2ff),
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
                  return _GaugeBar(
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
      ],
    );
  }
}

class _GaugeBar extends StatelessWidget {
  const _GaugeBar({
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            iconPath: 'assets/images/shopIcon.png',
            label: 'Loja',
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ShopScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          Container(height: 50, width: 2, color: const Color(0xFF6E4A2E)),
          _NavItem(
            iconPath: 'assets/images/battleIcon.png',
            label: 'Batalha',
            isSelected: true,
            onTap: () {},
          ),
          Container(height: 50, width: 2, color: const Color(0xFF6E4A2E)),
          _NavItem(
            iconPath: 'assets/images/matchIcon.png',
            label: 'Partidas',
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HistoryScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconPath,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFFF98B25)
        : const Color(0xFF8B5E3C);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 38, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontFamily: 'VT323', fontSize: 18, color: color),
          ),
        ],
      ),
    );
  }
}
