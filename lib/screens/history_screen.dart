// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:cajucards/models/player.dart';
import 'package:intl/intl.dart'; // Importe para formatação de data
import 'battle_screen.dart';
import 'shop_screen.dart';

// A tela principal (HistoryScreen) continua igual
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
                ],
              ),
            ),
            // O _MatchHistoryList agora buscará os dados
            const Expanded(child: _MatchHistoryList()),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// O _TopBar não muda.
class _TopBar extends StatelessWidget {
  final String playerName;
  final int coins;

  const _TopBar({required this.playerName, required this.coins});

  @override
  Widget build(BuildContext context) {
    // ... (código idêntico ao original)
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

// MODIFICAÇÃO: Convertido para StatefulWidget para buscar dados
class _MatchHistoryList extends StatefulWidget {
  const _MatchHistoryList({super.key});

  @override
  State<_MatchHistoryList> createState() => _MatchHistoryListState();
}

class _MatchHistoryListState extends State<_MatchHistoryList> {
  @override
  void initState() {
    super.initState();
    // Dispara a busca pelo histórico assim que o widget for construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verifica se o provider está montado antes de chamar
      if (mounted) {
        Provider.of<PlayerProvider>(context, listen: false).fetchMatchHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consome o PlayerProvider para obter os estados de histórico
    return Consumer<PlayerProvider>(
      builder: (context, provider, child) {
        // 1. Estado de Carregamento
        if (provider.isLoadingHistory) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // 2. Estado de Erro
        if (provider.historyError != null) {
          return Center(
            child: Text(
              provider.historyError!,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'VT323',
                fontSize: 24,
              ),
            ),
          );
        }

        // 3. Estado de Lista Vazia (Conforme solicitado)
        if (provider.matches.isEmpty) {
          return const Center(
            child: Text(
              'Sem registros de partidas',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'VT323',
                fontSize: 24,
              ),
            ),
          );
        }

        // 4. Estado de Sucesso (Lista Cheia)
        // Precisamos do ID do jogador logado para saber quem é o oponente
        final String currentUserId = provider.player!.id; // Assumindo que Player tem 'id'
        final DateFormat formatter = DateFormat('dd/MM/yyyy'); // Formatador de data

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: provider.matches.length, // Usa o tamanho real da lista
          itemBuilder: (context, index) {
            
            final match = provider.matches[index];

            // Lógica para determinar oponente e resultado
            final bool isPlayer1 = match.player1.id == currentUserId;
            final bool isWinner = match.winner.id == currentUserId;

            final String opponentName =
                isPlayer1 ? match.player2.username : match.player1.username;
            final String result = isWinner ? "Vitória" : "Derrota";
            
            // Formata a data
            final String date = formatter.format(match.matchDate);

            // Usa o _MatchHistoryCard original, passando os dados dinâmicos
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _MatchHistoryCard(
                opponentName: opponentName,
                result: result,
                date: date,
              ),
            );
          },
        );
      },
    );
  }
}

// _MatchHistoryCard NÃO MUDA (Conforme solicitado)
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
                opponentName, // <-- DADO DINÂMICO
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Cartas estáticas mantidas, conforme API atual
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
                result, // <-- DADO DINÂMICO
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 28,
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date, // <-- DADO DINÂMICO
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

// O _BottomNavBar não muda.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    // ... (código idêntico ao original)
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

// O _NavItem não muda.
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
    // ... (código idêntico ao original)
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