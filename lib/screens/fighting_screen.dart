import 'package:flutter/material.dart';
import 'dart:math' as math; // Para usar 'pi'

// Um widget reutilizável para o texto com contorno
class StrokedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const StrokedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'VT323',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'VT323',
            color: fillColor,
          ),
        ),
      ],
    );
  }
}

class FightingScreen extends StatelessWidget {
  const FightingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Layout responsivo usando MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo de madeira que cobre toda a tela
          Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),

          // Arenas do jogador e do oponente
          Column(
            children: [
              Expanded(
                child: _buildArena(isOpponent: true),
              ),
              Expanded(
                child: _buildArena(isOpponent: false),
              ),
            ],
          ),

          // HUD (Heads-Up Display) sobreposto
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Informações do Oponente (Topo)
                _PlayerInfoBar(
                  isOpponent: true,
                  playerName: "Oponente",
                  health: 100,
                  synergies: {
                    'assets/images/synergy_icon_1.png': 1,
                    'assets/images/synergy_icon_2.png': 2,
                  },
                ),

                // Espaço central do jogo (deixado vazio para as tropas)

                // Informações do Jogador e Mão de Cartas (Baixo)
                Column(
                  children: [
                    _PlayerInfoBar(
                      isOpponent: false,
                      playerName: "Você",
                      health: 100,
                      synergies: {
                        'assets/images/synergy_icon_3.png': 3,
                        'assets/images/synergy_icon_4.png': 1,
                      },
                    ),
                    const SizedBox(height: 10),
                    _PlayerHand(),
                  ],
                ),
              ],
            ),
          ),
          // Barra de Castanhas e botão de emotes
          _SideBar(),
        ],
      ),
    );
  }

  Widget _buildArena({required bool isOpponent}) {
    // Rotaciona a arena do oponente para dar a sensação de espelho
    return Transform(
      alignment: Alignment.center,
      transform: isOpponent ? (Matrix4.rotationX(math.pi)..rotateZ(math.pi)) : Matrix4.identity(),
      child: Image.asset(
        'assets/images/arena.png', // Use sua imagem de arena aqui
        fit: BoxFit.cover,
      ),
    );
  }
}

// Widget para a barra de informações do jogador/oponente
class _PlayerInfoBar extends StatelessWidget {
  final bool isOpponent;
  final String playerName;
  final int health;
  final Map<String, int> synergies;

  const _PlayerInfoBar({
    required this.isOpponent,
    required this.playerName,
    required this.health,
    required this.synergies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFFC4A474), // Cor de fundo da barra
      child: Row(
        children: [
          Image.asset(
            isOpponent ? 'assets/images/opponent_icon.png' : 'assets/images/player_icon.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StrokedText(
                text: playerName,
                fontSize: 24,
                fillColor: Colors.white,
                strokeColor: const Color(0xFF4B2D18),
              ),
              StrokedText(
                text: 'Vida: $health',
                fontSize: 18,
                fillColor: Colors.white,
                strokeColor: const Color(0xFF4B2D18),
              ),
            ],
          ),
          const Spacer(),
          // Ícones de sinergia
          Row(
            children: synergies.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.asset(entry.key, width: 40, height: 40),
                    StrokedText(
                      text: entry.value.toString(),
                      fontSize: 18,
                      fillColor: Colors.white,
                      strokeColor: Colors.black,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Widget para a mão de cartas do jogador
class _PlayerHand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF4B2D18).withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4, // 4 cartas na mão
          (index) => _CardInHand(
            cost: (index + 2), // Custo de exemplo
          ),
        ),
      ),
    );
  }
}

class _CardInHand extends StatelessWidget {
  final int cost;
  const _CardInHand({required this.cost});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset('assets/images/card_placeholder.png', fit: BoxFit.cover),
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: StrokedText(
                text: cost.toString(),
                fontSize: 16,
                fillColor: Colors.white,
                strokeColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para a barra lateral
class _SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 140, // Posiciona acima da mão de cartas
      child: Column(
        children: [
          // Barra de Castanhas (Energia)
          Container(
            width: 30,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF98B25).withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF4B2D18), width: 3),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 150, // Exemplo de preenchimento
                decoration: BoxDecoration(
                  color: const Color(0xFFF98B25),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const StrokedText(
            text: '4/16',
            fontSize: 20,
            fillColor: Colors.white,
            strokeColor: Colors.black,
          ),
          const SizedBox(height: 20),
          // Botão de Emotes
          Image.asset('assets/images/emote_button.png', width: 60),
        ],
      ),
    );
  }
}
