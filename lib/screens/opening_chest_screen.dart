// lib/screens/opening_chest_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cajucards/models/emote.dart'; // Importa o modelo Emote

// 1. Enum para controlar os estados da animação
enum AnimationPhase {
  shaking, // Sacudindo
  opening, // Mostrando baú aberto (transição)
  revealed // Revelando o emote
}

class OpeningChestScreen extends StatefulWidget {
  final String chestImagePath; // A imagem do baú que o usuário clicou
  final Emote wonEmote;      // O emote que a API retornou

  const OpeningChestScreen({
    super.key,
    required this.chestImagePath,
    required this.wonEmote,
  });

  @override
  State<OpeningChestScreen> createState() => _OpeningChestScreenState();
}

// 2. Adicionar 'with TickerProviderStateMixin' para a animação
class _OpeningChestScreenState extends State<OpeningChestScreen>
    with TickerProviderStateMixin {
  
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  AnimationPhase _phase = AnimationPhase.shaking;

  @override
  void initState() {
    super.initState();

    // 3. Configurar o controlador da animação de "sacudir"
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100), // Rápida vibração
      vsync: this,
    );

    // 4. Configurar a animação (vai de -0.1 a 0.1 radianos ~ 5 graus)
    _shakeAnimation = Tween<double>(begin: -0.1, end: 0.1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shakeController);

    // 5. Repetir a animação (indo e voltando)
    _shakeController.repeat(reverse: true);

    // 6. Iniciar a sequência de animação
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. SACUDIR por 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    
    // Parar de sacudir e mostrar o baú "abrindo"
    // (Se você tiver um sprite de baú aberto, trocaria a imagem aqui)
    _shakeController.stop();
    if (!mounted) return; // Verifica se o widget ainda está na tela
    setState(() {
      _phase = AnimationPhase.opening;
    });

    // 2. ESPERAR 1 segundo (enquanto o baú "abre")
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // 3. REVELAR o prêmio
    setState(() {
      _phase = AnimationPhase.revealed;
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita que o usuário volte acidentalmente
      body: WillPopScope(
        onWillPop: () async => false, // Desabilita o botão "Voltar"
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fundo da tela
            Image.asset('assets/images/WoodBasic.png', fit: BoxFit.cover),
            
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Conteúdo central que muda com a fase
                  _buildAnimationContent(),
                  
                  const Spacer(flex: 3),
                  
                  // Botão "Continuar" que só aparece no final
                  if (_phase == AnimationPhase.revealed)
                    _buildContinueButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Widget que constrói o conteúdo baseado na fase
  Widget _buildAnimationContent() {
    switch (_phase) {
      case AnimationPhase.shaking:
        // Envolve o baú com o RotationTransition para "sacudir"
        return RotationTransition(
          turns: _shakeAnimation,
          child: Image.asset(widget.chestImagePath, width: 250),
        );
        
      case AnimationPhase.opening:
        // TODO: Substitua pelo seu sprite de "baú abrindo" ou "baú aberto"
        // Por enquanto, apenas mostramos o baú estático.
        return Image.asset(widget.chestImagePath, width: 250);

      case AnimationPhase.revealed:
        // Revela o emote ganho
        return Column(
          children: [
            const Text(
              'Você conseguiu!',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 40,
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black, offset: Offset(2,2)),
                ]
              ),
            ),
            const SizedBox(height: 20),
            
            // Usa o 'spritePath' do seu modelo Emote
            Image.asset(
              widget.wonEmote.spritePath, 
              width: 200,
              fit: BoxFit.contain,
              // Adiciona um tratamento de erro caso o asset não seja encontrado
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.error_outline, color: Colors.white, size: 50),
                );
              },
            ),

            const SizedBox(height: 10),
            Text(
              widget.wonEmote.name,
              style: const TextStyle(
                fontFamily: 'VT323',
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black, offset: Offset(2,2)),
                ]
              ),
            ),
          ],
        );
    }
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF98B25), // Cor laranja
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: Color(0xFF4A321E), width: 3),
      ),
      onPressed: () {
        Navigator.pop(context); // Volta para a ShopScreen
      },
      child: const Text(
        'Continuar',
        style: TextStyle(
          fontFamily: 'VT323',
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}