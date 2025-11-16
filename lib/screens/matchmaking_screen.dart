import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:cajucards/api/services/socket_service.dart';
import 'package:cajucards/screens/battle_arena_screen.dart';

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

  Timer? _fallbackToBotTimer;
  bool _navigatedToMatch = false;

  // 🔹 Referência fixa pro SocketService (sem depender de context no dispose)
  late SocketService _socketService;

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
      if (!mounted) return; // proteção extra
      setState(() {
        if (_loadingDots.length < 3) {
          _loadingDots += '.';
        } else {
          _loadingDots = '';
        }
      });
    });

    _currentPhraseIndex = Random().nextInt(_phrases.length);

    _phrasesTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
      });
    });

    _startFallbackTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aqui ainda é seguro usar context.read
    _socketService = context.read<SocketService>();
  }

  @override
  void dispose() {
    // 1) Cancela timers/animadores
    _pulsarController.dispose();
    _dotsTimer?.cancel();
    _phrasesTimer?.cancel();
    _fallbackToBotTimer?.cancel();

    // 2) Usa a referência salva do SocketService (sem context.read)
    if (_socketService.status == MatchmakingStatus.searching) {
      _socketService.cancelFindMatch();
    }

    super.dispose();
  }

  void _startFallbackTimer() {
    _fallbackToBotTimer?.cancel();
    _fallbackToBotTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;

      // Usa a instância salva
      if (_socketService.status == MatchmakingStatus.searching) {
        _navigateToBattle(vsBot: true);
      }
    });
  }

  void _navigateToBattle({required bool vsBot}) {
    if (_navigatedToMatch || !mounted) {
      return;
    }

    _navigatedToMatch = true;
    _fallbackToBotTimer?.cancel();

    if (vsBot && _socketService.status == MatchmakingStatus.searching) {
      _socketService.cancelFindMatch();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BattleArenaScreen.bot(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  String _getTextoCarregamento(MatchmakingStatus status) {
    switch (status) {
      case MatchmakingStatus.searching:
        return 'Procurando oponente$_loadingDots';
      case MatchmakingStatus.inMatch:
        return 'Partida encontrada!';
      case MatchmakingStatus.idle:
        return 'Cancelado$_loadingDots';
      case MatchmakingStatus.error:
        return 'Erro ao conectar$_loadingDots';
    }
  }

  @override
  Widget build(BuildContext context) {
    const double tamanhoCastanha = 150.0;

    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        if (socketService.status == MatchmakingStatus.inMatch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToBattle(vsBot: false);
          });
        } else if (socketService.status == MatchmakingStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToBattle(vsBot: true);
          });
        }

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),

              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                ),
              ),

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
                      child: Image.asset('assets/images/caju.png', width: 100),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _getTextoCarregamento(socketService.status),
                      style: const TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 30,
                        color: Color(0xFFDD7326),
                      ),
                    ),
                  ],
                ),
              ),

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
                        image: AssetImage('assets/images/frasesContainer.png'),
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
        );
      },
    );
  }
}
