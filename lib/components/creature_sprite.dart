import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import 'package:cajucards/models/card.dart' as card_model;

class CreatureSprite extends SpriteComponent {
  final card_model.Card cardData;
  VoidCallback? onRemovedCallback;

  CreatureSprite({required this.cardData})
    : super(size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load('assets/images/sprites/${cardData.spritePath}');
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
