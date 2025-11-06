import 'package:cajucards/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:cajucards/models/player.dart';
import 'battle_screen.dart';

// 1. NOVOS IMPORTS ADICIONADOS
import 'package:cajucards/models/emote.dart';
import 'package:cajucards/screens/opening_chest_screen.dart';
// FIM DOS NOVOS IMPORTS

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

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
                      fontFamily: 'VT33',
                      fontSize: 24,
                    ),
                  ),
                )
              else if (playerProvider.player != null)
                // Passamos o jogador para o método que constrói o conteúdo
                _buildScreenContent(context, playerProvider.player!)
              else
                const Center(
                  child: Text(
                    'Nenhum dado de jogador encontrado.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              
              // 2. ADICIONADO: Lógica de loading (como na login_screen)
              // Essencial para feedback e para evitar múltiplos cliques.
              if (playerProvider.isBuyingChest)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Processando compra...',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'VT323',
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // FIM DA ADIÇÃO
            ],
          ),
        );
      },
    );
  }

  // NENHUMA ALTERAÇÃO NESTE MÉTODO
  Widget _buildScreenContent(BuildContext context, Player player) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _TopBar(
                    // 4. Usamos os dados dinâmicos do jogador
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
            // O conteúdo principal da loja (seleção de baús)
            const Expanded(child: Center(child: _ChestSelection())),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// NENHUMA ALTERAÇÃO NESTE WIDGET
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

// NENHUMA ALTERAÇÃO NESTE WIDGET
class _ChestSelection extends StatelessWidget {
  const _ChestSelection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ChestCard(
          backgroundPath: 'assets/images/cardMercurio.png',
          imagePath: 'assets/images/bauMercurio.png',
          name: 'Baú Mercúrio',
          price: 200,
        ),
        _ChestCard(
          backgroundPath: 'assets/images/cardPlutonio.png',
          imagePath: 'assets/images/bauPlutonio.png',
          name: 'Baú Plutônio',
          price: 300,
        ),
        _ChestCard(
          backgroundPath: 'assets/images/cardUranio.png',
          imagePath: 'assets/images/bauUranio.png',
          name: 'Baú Urânio',
          price: 400,
        ),
      ],
    );
  }
}

// 3. ALTERAÇÕES LÓGICAS NESTE WIDGET
class _ChestCard extends StatelessWidget {
  final String backgroundPath;
  final String imagePath;
  final String name;
  final int price;

  const _ChestCard({
    required this.backgroundPath,
    required this.imagePath,
    required this.name,
    required this.price,
  });

  // 4. ADICIONADO: Método de "toast" de erro (copiado da login_screen)
  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF8C1C13), // Cor vermelha do erro
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5A0000), width: 3),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline, // Ícone de erro
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. ADICIONADO: Lógica de compra
  void _handleBuyChest(BuildContext context) async {
    final provider = context.read<PlayerProvider>();

    // Proteção contra múltiplos cliques
    if (provider.isBuyingChest) return;

    provider.clearBuyChestError();

    // Chama a API
    final bool success = await provider.buyChest(name, price);

    // Verifica se o widget ainda está montado
    if (!context.mounted) return;

    if (success) {
      // SUCESSO: Navega para a tela de abertura
      final Emote? wonEmote = provider.lastWonEmote;
      if (wonEmote != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpeningChestScreen(
              chestImagePath: imagePath,
              wonEmote: wonEmote,
            ),
          ),
        );
      }
    } else {
      // FALHA: Mostra o "toast" de erro, como na login_screen
      final String error = provider.buyChestError ?? "Ocorreu um erro.";
      _showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 6. ALTERADO: O onTap agora chama a lógica
      onTap: () => _handleBuyChest(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(backgroundPath, width: 200),
              Image.asset(imagePath, width: 170),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'VT323',
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                price.toString(),
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 9.0),
                child: Image.asset('assets/images/cajucoin.png', width: 50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// NENHUMA ALTERAÇÃO NESTE WIDGET
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
            isSelected: true,
            onTap: () {},
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
                ),
              );
            },
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// NENHUMA ALTERAÇÃO NESTE WIDGET
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