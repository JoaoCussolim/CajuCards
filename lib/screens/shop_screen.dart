import 'package:flutter/material.dart';
import 'battle_screen.dart'; // Importa a tela de batalha para navegação

// Futuramente, você importará as outras telas aqui
// import 'history_screen.dart';
// import 'open_chest_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // Dados estáticos como solicitado
  final String _playerName = "Miguelzinho";
  final int _playerCoins = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                  const Flexible(
                    child: Center(
                      child: _ChestSelection(),
                    ),
                  ),
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

// --- WIDGET ATUALIZADO ---

/// **Barra Superior com espaçamento interno e alinhamento corrigidos.**
class _TopBar extends StatelessWidget {
  final String playerName;
  final int coins;

  const _TopBar({required this.playerName, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Camada 1: A imagem de fundo.
        Image.asset('assets/images/userContainer.png'),

        // Camada 2: O conteúdo sobreposto com padding generoso.
        Padding(
          // **CORREÇÃO:** Padding horizontal aumentado para centralizar o texto
          // e um padding vertical para o ajuste fino do alinhamento.
          padding: const EdgeInsets.fromLTRB(50.0, 4.0, 50.0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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


// --- WIDGETS INALTERADOS (JÁ ESTAVAM CORRETOS) ---

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Navegar para a tela de abrir o $name"),
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
            style: const TextStyle(fontFamily: 'VT323', fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                price.toString(),
                style: const TextStyle(fontFamily: 'VT323', fontSize: 26, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Image.asset('assets/images/cajucoin.png', width: 26),
            ],
          ),
        ],
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
              print("Navegar para a HistoryScreen");
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