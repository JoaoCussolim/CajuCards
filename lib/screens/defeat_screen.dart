import 'package:cajucards/screens/battle_screen.dart';
import 'package:flutter/material.dart';

class DefeatScreen extends StatelessWidget {
  const DefeatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/WoodBasic.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStrokedText(
                  'Derrota',
                  80,
                  const Color(0xFFDC3545),
                  4.0,
                  const Color(0xFF4B2D18),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/castanha1.png', // Uma imagem diferente para a derrota
                  width: 150,
                ),
                const SizedBox(height: 40),
                _buildStrokedText(
                  'Mais sorte na próxima vez!',
                  30,
                  Colors.white,
                  2.0,
                  const Color(0xFF4B2D18),
                ),
                const SizedBox(height: 60),
                _buildContinueButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokedText(
    String text,
    double fontSize,
    Color fillColor,
    double strokeWidth,
    Color strokeColor,
  ) {
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

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundoInput.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: const Text(
          'Voltar ao Menu',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'VT323',
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}