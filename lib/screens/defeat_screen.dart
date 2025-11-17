import 'package:cajucards/screens/matchmaking_screen.dart';
import 'package:flutter/material.dart';
import 'package:cajucards/screens/battle_screen.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/api/services/socket_service.dart';

// 1. Convertido para StatefulWidget
class DefeatScreen extends StatefulWidget {
  const DefeatScreen({super.key});

  @override
  State<DefeatScreen> createState() => _DefeatScreenState();
}

// 2. Adicionado o SingleTickerProviderStateMixin
class _DefeatScreenState extends State<DefeatScreen>
    with SingleTickerProviderStateMixin {
  // 3. Adicionada a lógica de animação
  late AnimationController _pulsarController;
  late Animation<double> _pulsarAnimation;

  @override
  void initState() {
    super.initState();

    _pulsarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulsarAnimation = Tween<double>(begin: 0.0, end: -15.0).animate(
      CurvedAnimation(parent: _pulsarController, curve: Curves.easeInOut),
    );

    _pulsarController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 4. Controller é descartado
    _pulsarController.dispose();
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
                Image.asset(
                  'assets/images/defeat.png',
                  width: 600,
                  height: 200,
                ),
                const SizedBox(height: 40),
                _buildStrokedText(
                  'Jogar de Novo?',
                  60,
                  const Color(0xFFDDC174),
                  2.0,
                  const Color(0xFF4B2D18),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOptionButton(
                      context: context,
                      text: 'Sim',
                      onTap: () {
                        Provider.of<SocketService>(context, listen: false)
                                  .findMatch();

                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const MatchmakingScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                      },
                    ),
                    const SizedBox(width: 40),
                    _buildOptionButton(
                      context: context,
                      text: 'Não',
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
                  ],
                ),

                // 5. ANIMAÇÃO APLICADA AQUI
                // O caju triste no centro, agora pulando
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _pulsarAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _pulsarAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/caju.png',
                    width: 150,
                  ),
                ),
                const SizedBox(height: 40),
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

  Widget _buildOptionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/button.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: _buildStrokedText(
          text,
          70,
          const Color(0xFFFFFFFF),
          2.0,
          const Color(0xFF301F18),
        ),
      ),
    );
  }
}