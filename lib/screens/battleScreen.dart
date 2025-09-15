import 'package:flutter/material.dart';

// --- Constantes e Variáveis Globais ---
const Color kBackgroundColor = Color(0xFF2E2E2E);
const Color kAppBarTextColor = Color(0xFF4B2D18);
const Color kButtonTextColor = Colors.white;
const Color kSelectedNavColor = Color(0xFFF98B25);
const Color kDefaultNavColor = Color(0xFF8B5E3C);
const Color kDividerColor = Color(0xFF6E4A2E);

const String kPixelFont = 'VT323-Regular';
final double tamanhoCastanha = 180.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BattleScreen(),
    );
  }
}

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Fundo
            Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),

            Positioned(
              top: 140,
              left: 40,
              child: Image.asset('assets/images/Castanha1Cima.png', width: tamanhoCastanha),
            ),
            Positioned(
              top: 140,
              right: 40,
              child: Image.asset('assets/images/Castanha2Cima.png', width: tamanhoCastanha),
            ),
            Positioned(
              bottom: 120,
              left: 40,
              child: Image.asset('assets/images/Castanha1Baixo.png', width: tamanhoCastanha),
            ),
            Positioned(
              bottom: 120,
              right: 40,
              child: Image.asset('assets/images/Castanha2Baixo.png', width: tamanhoCastanha),
            ),

            // 3. Conteúdo Principal da Tela
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // AJUSTE DE ALINHAMENTO FEITO AQUI
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: _TopBar(
                          playerName: "Miguelzinho",
                          coins: 500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Envolvemos a engrenagem num Padding para subir ela um pouco
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Image.asset(
                          'assets/images/Gear.png',
                          width: 45,
                        ),
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
      ),
    );
  }
}

// AJUSTE DE ALINHAMENTO FEITO AQUI
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
        // Usamos fromLTRB para ter controle fino do padding (left, top, right, bottom)
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 4, 20, 0),
          child: Row(
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  fontFamily: kPixelFont,
                  // Fonte reduzida para caber corretamente
                  fontSize: 32,
                  color: kAppBarTextColor,
                ),
              ),
              const Spacer(),
              Image.asset('assets/images/cajucoin.png', width: 28),
              const SizedBox(width: 10),
              Text(
                coins.toString(),
                style: const TextStyle(
                  fontFamily: kPixelFont,
                  // Fonte igualada à do nome para consistência
                  fontSize: 32,
                  color: kAppBarTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget para o botão central
class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Iniciar Partida clicado!");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/buttonBattle.png',
            width: 400,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
          ),
        ],
      ),
    );
  }
}

// Widget para a barra de navegação inferior
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _NavItem(
            iconPath: 'assets/images/shopIcon.png',
            label: 'Loja',
          ),
          Container(height: 50, width: 2, color: kDividerColor),
          const _NavItem(
            iconPath: 'assets/images/battleIcon.png',
            label: 'Batalha',
            isSelected: true,
          ),
          Container(height: 50, width: 2, color: kDividerColor),
          const _NavItem(
            iconPath: 'assets/images/matchIcon.png',
            label: 'Partidas',
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

  const _NavItem({
    required this.iconPath,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? kSelectedNavColor : kDefaultNavColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconPath, width: 38, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: kPixelFont,
            fontSize: 18,
            color: color,
          ),
        )
      ],
    );
  }
}