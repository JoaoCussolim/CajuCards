import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// TODO: Se a tela de batalha for o próximo passo, importe-a.
// import 'package:cajucards/screens/battle_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  // --- Animação do Caju ---
  late AnimationController _pulsarController;
  late Animation<double> _pulsarAnimation;

  // --- Animação dos Pontos "Carregando..." ---
  Timer? _dotsTimer;
  String _loadingDots = '';

  // --- Animação das Frases ---
  Timer? _phrasesTimer;
  int _currentPhraseIndex = 0;
  final List<String> _phrases = [
    "Você sabia que caju é um pseudofruto? O fruto, na verdade, é a castanha!",
    "A escolha do caju é na verdade uma homenagem a um velho amigo...",
    "Sabia que o caju é uma fruta nativa do Brasil?",
    "Há lendas sobre um site chamado Cajuice... idiota não é? (Acesse cajuice.vercel.app)",
    "Será que em um mundo de pessoas caju... todas as castanhas seriam castanhas de caju?",
    "Sabia que caju em inglês é cashew? cashew nut = castanha; cashew apple = fruta",
  ];

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

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingDots.length < 3) {
            _loadingDots += '.';
          } else {
            _loadingDots = '';
          }
        });
      }
    });

    _currentPhraseIndex = Random().nextInt(_phrases.length);

    _phrasesTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        /*
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BattleScreen()),
        );
        */
      }
    });
  }

  @override
  void dispose() {
    _pulsarController.dispose();
    _dotsTimer?.cancel();
    _phrasesTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tamanhoCastanha = 150.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo
          Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),

          // 1. Logo posicionada no topo
          SafeArea(
            // SafeArea evita que a logo cole na barra de status do celular
            child: Align(
              alignment: Alignment.topCenter, // Alinha no centro do topo
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ), // Ajuste esse valor para descer mais ou menos
                child: Image.asset(
                  'assets/images/Logo.png',
                  width:
                      MediaQuery.of(context).size.width *
                      0.6, // Aumentei um pouco pra dar mais destaque, ajuste como preferir
                ),
              ),
            ),
          ),

          // 2. Caju e texto centralizados (sem a logo)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulsarAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _pulsarAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/caju.png', //
                    width: 100,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Carregando$_loadingDots',
                  style: const TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 30,
                    color: Color(0xFFDD7326),
                  ),
                ),
              ],
            ),
          ),
          // --- FIM DO AJUSTE ---

          // Container de frases na parte inferior
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/frasesContainer.png'), //
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      _phrases[_currentPhraseIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 36,
                        color: Color(0xFFDD7326),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Castanhas nos cantos
          Positioned(
            top: 10,
            left: 10,
            child: Image.asset(
              'assets/images/Castanha1Cima.png', //
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Image.asset(
              'assets/images/Castanha2Cima.png', //
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Image.asset(
              'assets/images/Castanha1Baixo.png', //
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Image.asset(
              'assets/images/Castanha2Baixo.png', //
              width: tamanhoCastanha,
            ),
          ),
        ],
      ),
    );
  }
}
