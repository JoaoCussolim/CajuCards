import 'package:cajucards/screens/matchmaking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o provider
import 'package:cajucards/providers/player_provider.dart'; // Importe seu provider
import 'package:cajucards/models/player.dart';
import 'shop_screen.dart';
import 'history_screen.dart';

// --- ADICIONADO ---
// Importe o SocketService para que possamos chamá-lo
import 'package:cajucards/api/services/socket_service.dart';
// --- FIM DA ADIÇÃO ---

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const _StartButton(),
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

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // --- INÍCIO DA ALTERAÇÃO LÓGICA ---
      onTap: () {
        // 1. Pega o SocketService (sem escutar)
        final socketService = context.read<SocketService>();

        // 2. Inicia a busca pela partida
        socketService.findMatch();
        debugPrint(
            "BattleScreen: Chamando findMatch() e navegando para Matchmaking...");

        // 3. Navega para a tela de Matchmaking (como você já fazia)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MatchmakingScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      // --- FIM DA ALTERAÇÃO LÓGICA ---
      child: Stack(
        alignment: Alignment.center,
        children: [Image.asset('assets/images/buttonBattle.png', width: 600)],
      ),
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