import 'package:cajucards/screens/battle_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Usaremos sin e pi para a animação de onda

class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with SingleTickerProviderStateMixin {
  // Agora precisamos apenas de UM controller
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // O controller agora simplesmente repete de 0.0 a 1.0
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Um pouco mais lento
    )..repeat(); // Sem 'reverse'
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                SizedBox(
                  width: 600,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/images/banner.png', width: 600),

                      // ORDEM DA ANIMAÇÃO INVERTIDA
                      Positioned(
                        top: 55,
                        left: 110,
                        child: _buildAnimatedStar(
                          _controller,
                          120,
                          0.3,
                        ), // Começa por último
                      ),
                      Positioned(
                        top: 0,
                        left: 230,
                        child: _buildAnimatedStar(
                          _controller,
                          150,
                          0.15,
                        ), // Continua no meio
                      ),
                      Positioned(
                        top: 55,
                        right: 110,
                        child: _buildAnimatedStar(
                          _controller,
                          110,
                          0.0,
                        ), // Começa primeiro
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/victory.png',
                  height: 150,
                  width: 500,
                ),
                const SizedBox(height: 100),
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
                          const SizedBox(width: 20),
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

  // Widget da estrela foi modificado para receber o atraso (phaseDelay)
  Widget _buildAnimatedStar(
    Animation<double> controller,
    double size,
    double phaseDelay,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // A matemática da onda acontece aqui!
        final time = (controller.value + phaseDelay) % 1.0;
        final yOffset =
            sin(time * 2 * pi) *
            7.5; // Multiplica por 2*pi para um ciclo completo

        return Transform.translate(offset: Offset(0, yOffset), child: child);
      },
      child: Image.asset('assets/images/star.png', width: size),
    );
  }

  // O resto do seu código permanece o mesmo
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
