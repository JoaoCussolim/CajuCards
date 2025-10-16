import 'package:flame/components.dart';
import 'package:cajucards/models/card.dart' as card_model;

class CreatureSprite extends SpriteComponent {
  final card_model.Card cardData;

  CreatureSprite({required this.cardData})
    : super(size: Vector2.all(64)); // Tamanho do "bixo"

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load(cardData.spritePath);
  }
}
