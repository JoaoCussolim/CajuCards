import 'package:flutter/material.dart';
import 'dart:async'; 
// NOVO: Importe o arquivo da tela de batalha
import 'package:cajucards/screens/battle_screen.dart'; 

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen>
    with SingleTickerProviderStateMixin {
  final double tamanhoCastanha = 250.0;

  double _opacidadeConteudo = 0.0;

  late AnimationController _pulsarController;
  late Animation<double> _pulsarAnimation;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacidadeConteudo = 1.0;
        });
      }
    });

    _pulsarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulsarAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _pulsarController, curve: Curves.easeInOut),
    );

    _pulsarController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulsarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // ALTERADO: Navega para a BattleScreen quando a tela é tocada
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BattleScreen()),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/WoodBasic.png',
              fit: BoxFit.cover,
            ),
            AnimatedOpacity(
              opacity: _opacidadeConteudo,
              duration: const Duration(seconds: 2),
              curve: Curves.easeIn,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo.png',
                      width: MediaQuery.of(context).size.width * 0.44,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _pulsarAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _pulsarAnimation.value),
                          child: child,
                        );
                      },
                      child: const Text(
                        'Pressione qualquer botão para iniciar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 50,
                          color: Color(0xFFDD7326),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Image.asset(
                'assets/images/Castanha1Cima.png',
                width: tamanhoCastanha,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Image.asset(
                'assets/images/Castanha2Cima.png',
                width: tamanhoCastanha,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Image.asset(
                'assets/images/Castanha1Baixo.png',
                width: tamanhoCastanha,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Image.asset(
                'assets/images/Castanha2Baixo.png',
                width: tamanhoCastanha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}