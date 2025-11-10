import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import 'package:cajucards/models/card.dart' as card_model;

String _resolveSpriteAssetPath(String rawPath) {
  if (rawPath.startsWith('assets/')) {
    return rawPath;
  }
  if (rawPath.startsWith('images/')) {
    return 'assets/$rawPath';
  }
  if (rawPath.startsWith('sprites/')) {
    return 'assets/images/$rawPath';
  }
  if (!rawPath.contains('/')) {
    return 'assets/images/sprites/$rawPath';
  }
  return 'assets/images/$rawPath';
}

class CreatureSprite extends SpriteComponent {
  final card_model.TroopCard cardData;
  VoidCallback? onRemovedCallback;

  CreatureSprite({required this.cardData})
    : super(size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final spritePath = _resolveSpriteAssetPath(cardData.spritePath);

    try {
      sprite = await Sprite.load(spritePath);
    } catch (error, stackTrace) {
      debugPrint('Falha ao carregar sprite da criatura "$spritePath": $error');
      debugPrint('$stackTrace');
      final fallbackPath = _resolveSpriteAssetPath('sprites/card_base.png');
      sprite = await Sprite.load(fallbackPath);
    }
  }

  Future<void> attack() async {
    const double attackAngle =
        math.pi / 3;

    final attackEffect = RotateEffect.to(
      attackAngle,
      EffectController(
        duration: 0.15,
        reverseDuration: 0.15,
      ),
    );

    await add(attackEffect);
  }

  @override
  void onRemove() {
    super.onRemove();
    onRemovedCallback?.call();
  }

}
