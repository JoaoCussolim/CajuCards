import 'package:cajucards/screens/matchmaking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:cajucards/models/player.dart';
import 'shop_screen.dart';
import 'history_screen.dart';
import 'package:cajucards/api/services/socket_service.dart';
import 'pve_battle_screen.dart';

enum BattleMode { pvp, pve }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  BattleMode _selectedMode = BattleMode.pvp;
  bool _launchingPve = false;

  @override
  void _onModeSelected(BattleMode mode) {
    if (_selectedMode == mode) {
      return;
    }

    setState(() {
      _selectedMode = mode;
    });
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

  Future<void> _openPveBattle() async {
    if (_launchingPve) {
      return;
    }

    setState(() {
      _launchingPve = true;
    });

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PveBattleScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _launchingPve = false;
    });
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
                        : _PvePanel(
                            key: const ValueKey('pve-mode'),
                            onLaunch: _openPveBattle,
                            isLoading: _launchingPve,
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
            label: 'PvE Contra Bot',
            isSelected: selectedMode == BattleMode.pve,
            onTap: () => onSelected(BattleMode.pve),
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
          child: Image.asset('assets/images/buttonBattle.png', width: 520),
        ),
      ],
    );
  }
}

class _PvePanel extends StatelessWidget {
  const _PvePanel({
    super.key,
    required this.onLaunch,
    required this.isLoading,
  });

  final VoidCallback onLaunch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Enfrente um bot local usando o mesmo campo das batalhas normais!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'VT323',
            fontSize: 26,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Teste decks, explore biomas e aprenda o ritmo da partida antes de desafiar outros jogadores.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'VT323',
            fontSize: 22,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: isLoading ? null : onLaunch,
          child: Opacity(
            opacity: isLoading ? 0.6 : 1,
            child: Image.asset('assets/images/buttonBattle.png', width: 420),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Carregando arena PvE...',
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 22,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
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
