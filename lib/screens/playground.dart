import 'package:cajucards/api/api_client.dart';
import 'package:cajucards/api/services/card_service.dart';
import 'package:cajucards/api/services/socket_service.dart';
import 'package:cajucards/components/card_sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:cajucards/models/card.dart' as card_model;

class CajuPlaygroundGame extends FlameGame with TapCallbacks  {
  final SocketService socketService;
  CajuPlaygroundGame({required this.socketService});

  @override
  Color backgroundColor() => const Color(0xFF2a2e42);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final cardService = CardService(ApiClient());

    try {
      final List<card_model.Card> allCards = await cardService.getAllCards();

      double xPos = 50.0;
      double yPos = 50.0;
      const double xGap = 120.0;
      const double yGap = 160.0;

      for (var cardData in allCards) {
        final cardSprite = CardSprite(
          card: cardData,
          socketService: socketService,
        )..position = Vector2(xPos, yPos);

        add(cardSprite);

        xPos += xGap;
        if (xPos > size.x - 100) {
          xPos = 50.0;
          yPos += yGap;
        }
      }
    } catch (e, stackTrace) {
      print("--- ERRO AO CARREGAR CARTAS DA API ---"); 
      print(e);
      print(stackTrace);
    }
  }
}

// Passo 2: O Widget que exibe o jogo na tela
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final CajuPlaygroundGame _game;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _game = CajuPlaygroundGame(socketService: _socketService);
    _socketService.connectAndListen();
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CajuCards Playground'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GameWidget(game: _game),
    );
  }
}
