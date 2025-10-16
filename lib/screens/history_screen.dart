import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:cajucards/models/player.dart';
import 'battle_screen.dart';
import 'shop_screen.dart';

// A tela principal (HistoryScreen) continua igual, já estava certa.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),
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
                _buildScreenContent(context, playerProvider.player!)
              else
                const Center(
                  child: Text(
                    'Nenhum dado de jogador encontrado.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScreenContent(BuildContext context, Player player) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
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
            ),
            const Expanded(child: _MatchHistoryList()),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// O _TopBar também já estava ok.
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
          decoration: const BoxDecoration(
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

// _MatchHistoryList também estava ok.
class _MatchHistoryList extends StatelessWidget {
  const _MatchHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 3,
      itemBuilder: (context, index) {
        final List<Map<String, dynamic>> matchData = [
          {
            'opponent': 'OdiadorDoMiguel',
            'result': 'Derrota',
            'date': '22/09/2025',
          },
          {
            'opponent': 'GostadorDoMiguel',
            'result': 'Vitória',
            'date': '22/09/2025',
          },
          {
            'opponent': 'OfficialClashRoyale',
            'result': 'Vitória',
            'date': '22/09/2025',
          },
        ];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _MatchHistoryCard(
            opponentName: matchData[index]['opponent'],
            result: matchData[index]['result'],
            date: matchData[index]['date'],
          ),
        );
      },
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  final String opponentName;
  final String result; // "Vitória" ou "Derrota"
  final String date;

  const _MatchHistoryCard({
    required this.opponentName,
    required this.result,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = (result == 'Vitória')
        ? const Color(0xFF27A844)
        : const Color(0xFFDC3545);

    // Trocamos o Stack por um Container com DecorationImage
    return Container(
      // O padding agora é do próprio container, alinhando o conteúdo interno
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/historyContainer.png'),
          // BoxFit.fill estica a imagem para preencher o container.
          // Se a imagem estiver distorcendo, talvez precise ajustar a altura
          // do container ou usar outro BoxFit.
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Coluna da Esquerda (Oponente e Cartas)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
            children: [
              Text(
                opponentName,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/images/cardPlutonio.png',
                      width: 45,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Coluna da Direita (Resultado e Data)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
            children: [
              Text(
                result,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 28,
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 22,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// O _BottomNavBar já estava ok
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
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const BattleScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          Container(height: 50, width: 2, color: const Color(0xFF6E4A2E)),
          _NavItem(
            iconPath: 'assets/images/matchIcon.png',
            label: 'Partidas',
            isSelected: true,
            onTap: () {},
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
    final color =
        isSelected ? const Color(0xFFF98B25) : const Color(0xFF8B5E3C);
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