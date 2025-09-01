import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para usar o Timer

// 1. Convertemos o widget para StatefulWidget para poder gerenciar o estado das animações.
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

// 2. Adicionamos 'with SingleTickerProviderStateMixin' para a animação.
class _InitialScreenState extends State<InitialScreen>
    with SingleTickerProviderStateMixin {
  final double tamanhoCastanha = 250.0;

  // Variável de estado para a animação de FADE-IN
  double _opacidadeConteudo = 0.0;

  // Variáveis para a animação de PULAR (movimento vertical)
  late AnimationController _pulsarController;
  late Animation<double> _pulsarAnimation;

  @override
  void initState() {
    super.initState();

    // --- LÓGICA DA ANIMAÇÃO 1: FADE-IN (APARECER) ---
    // Após 500 milissegundos, a opacidade muda para 1.0, ativando a animação.
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) { // Boa prática: verifica se o widget ainda está na tela
        setState(() {
          _opacidadeConteudo = 1.0;
        });
      }
    });

    // --- LÓGICA DA ANIMAÇÃO 2: PULAR (MOVIMENTO VERTICAL SUAVE) ---
    _pulsarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duração de um ciclo completo (sobe e desce)
    );

    // O valor irá de 0 (posição original) a -10 (10 pixels para cima).
    _pulsarAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _pulsarController, curve: Curves.easeInOut),
    );

    // Inicia a animação para repetir indefinidamente (indo e voltando)
    _pulsarController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 3. É crucial descartar o controller para liberar recursos e evitar vazamentos de memória.
    _pulsarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          print("Tela tocada! Iniciando o jogo...");
          // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => JogoScreen()));
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
                      'assets/images/Logoteste.png',
                      width: MediaQuery.of(context).size.width * 0.44,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),

                    AnimatedBuilder(
                      animation: _pulsarAnimation,
                      builder: (context, child) {
                        // Usamos Transform.translate para mover o widget no eixo Y
                        // de acordo com o valor atual da animação.
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

            // Decorações nos Cantos
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

