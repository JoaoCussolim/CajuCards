import 'package:flutter/material.dart';
import 'battle_screen.dart';
import 'shop_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Dados estáticos para a tela
  final String _playerName = "Miguelzinho";
  final int _playerCoins = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Imagem de fundo
          Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // 2. Barra Superior (Player + Moedas + Config)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _TopBar(
                            playerName: _playerName,
                            coins: _playerCoins,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Image.asset('assets/images/Gear.png', width: 45),
                        ),
                      ],
                    ),
                  ),

                  // 3. Conteúdo Central (Lista de Partidas Rolável)
                  Expanded(
                    child: _MatchHistoryList(),
                  ),

                  // 4. Barra de Navegação Inferior
                  const _BottomNavBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// **Barra Superior com informações do jogador.**
class _TopBar extends StatelessWidget {
  final String playerName;
  final int coins;

  const _TopBar({required this.playerName, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/images/userContainer.png'),
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 4.0, 20.0, 0),
          child: Row(
            children: [
              Text(
                playerName,
                style: const TextStyle(fontFamily: 'VT323', fontSize: 32, color: Color(0xFF4B2D18)),
              ),
              const Spacer(),
              Image.asset('assets/images/cajucoin.png', width: 28),
              const SizedBox(width: 10),
              Text(
                coins.toString(),
                style: const TextStyle(fontFamily: 'VT323', fontSize: 32, color: Color(0xFF4B2D18)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// **Lista rolável que contém os cards de histórico.**
class _MatchHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usamos o ListView.builder para criar uma lista rolável
    return ListView.builder(
      // Remove o padding padrão do topo para não ter espaçamento extra
      padding: EdgeInsets.zero,
      itemCount: 3, // Número de partidas para exibir (pode ser alterado)
      itemBuilder: (context, index) {
        // Dados estáticos de exemplo
        final List<Map<String, dynamic>> matchData = [
          {
            'opponent': 'OdiadorDoMiguel',
            'result': 'Derrota',
            'date': '22/09/2025'
          },
          {
            'opponent': 'GostadorDoMiguel',
            'result': 'Vitória',
            'date': '22/09/2025'
          },
          {
            'opponent': 'OfficialClashRoyale',
            'result': 'Vitória',
            'date': '22/09/2025'
          }
        ];

        return Padding(
          // Espaçamento entre os cards
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

/// **Card individual que mostra o resultado de uma partida.**
/// **Card individual que mostra o resultado de uma partida.**
/// (WIDGET ATUALIZADO PARA CORRIGIR O LAYOUT)
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
    // Define a cor do texto do resultado com base na vitória ou derrota
    final resultColor = (result == 'Vitória') ? const Color(0xFF27A844) : const Color(0xFFDC3545);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Imagem de fundo do container
        Image.asset('assets/images/historyContainer.png'),

        // Conteúdo do card
        Padding(
          // Aumentamos o padding para dar mais respiro aos elementos
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Coluna da Esquerda (Oponente e Cartas)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponentName,
                    style: const TextStyle(fontFamily: 'VT323', fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Row para as imagens das cartas
                  Row(
                    children: List.generate(5, (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset('assets/images/cardPlutonio.png', width: 45),
                    )),
                  ),
                ],
              ),
              
              // Coluna da Direita (Resultado e Data)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result,
                    style: TextStyle(fontFamily: 'VT323', fontSize: 28, color: resultColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date,
                    style: const TextStyle(fontFamily: 'VT323', fontSize: 22, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// **Barra de Navegação Inferior.**
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
            isSelected: true, // Item atual selecionado
            onTap: () {}, // Não faz nada, pois já estamos nesta tela
          ),
        ],
      ),
    );
  }
}

/// **Widget para um item da barra de navegação.**
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
    final color = isSelected ? const Color(0xFFF98B25) : const Color(0xFF8B5E3C);
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
          )
        ],
      ),
    );
  }
}