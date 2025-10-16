import 'package:cajucards/screens/battle_screen.dart'; // Ou a tela para onde você quer ir
import 'package:flutter/material.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
         
          Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),

          Positioned(
            bottom: 120,
            left: 100,
            child: Transform.rotate(
              angle: 0.2, 
              child: Image.asset('assets/images/folha.png', width: 120),
            ),
          ),

          
          Positioned(
            bottom: 70,
            left: 170,
            child: Transform.rotate(
              angle: -0.6,
              child: Image.asset('assets/images/folha.png', width: 100),
            ),
          ),

          
          Positioned(
            top: 0,
            right: 150,
            child: Transform.rotate(
              angle: 0.2,
              child: Image.asset('assets/images/folha.png', width: 125),
            ),
          ),

          
          Positioned(
            top: 90,
            right: 120,
            child: Transform.rotate(
              angle: 0.8,
              child: Image.asset('assets/images/folha.png', width: 105),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Image.asset(
                  'assets/images/starBanner.png',
                  width: 600, 
                ),
                const SizedBox(height: 0), 
                
                Image.asset(
                  'assets/images/victory.png',
                  height: 300,
                  width: 600,
                ),
                const SizedBox(
                  height: 0,
                ), 
                Container(
                  width: 600,
                  height: 150,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/frasesContainer.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Image.asset(
                            'assets/images/cajucoin2.png',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(width: 10),
                          _buildStrokedText(
                            '+1000', 
                            60, 
                            Colors.white,
                            2.0,
                            const Color(0xFF4B2D18),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: _buildExitButton(context),
                      ),
                    ],
                  ),
                ),
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


  Widget _buildExitButton(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/button.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: _buildStrokedText(
          'Sair',
          70,
          const Color(0xFFFFFFFF),
          2.0,
          const Color(0xFF301F18),
        ),
      ),
    );
  }
}
