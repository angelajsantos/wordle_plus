/// Tile Component:
///   ARCHIVED: tile and paint with animations in flame

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../core/models/letter_status.dart';


class TileComponent extends PositionComponent {
  String letter = '';
  LetterStatus status = LetterStatus.unknown;

  TileComponent({Vector2? pos, Vector2? sizePx}) {
    position = pos ?? Vector2.zero();
    size = sizePx ?? Vector2(48, 48);
    anchor = Anchor.center;
  }

  // rendering stuff
  @override
  void render(Canvas canvas) {
    // draw tile background
    final rect = size.toRect();
    final paint = Paint()..color = _colorFor(status);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );

    if (letter.isNotEmpty) {
      // center the letter
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = rect.center.dx - tp.width / 2;
      final dy = rect.center.dy - tp.height / 2;
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  // animation stuff
  Future<void> flipTo(LetterStatus next) async {
    // Scale Y down → swap color → back up
    final half = ScaleEffect.to(
      Vector2(1, 0.01),
      EffectController(duration: 0.12),
      onComplete: () => status = next,
    );
    final up = ScaleEffect.to(
      Vector2(1, 1),
      EffectController(duration: 0.12),
    );
    await add(SequenceEffect([half, up], alternate: false));
  }


  Future<void> shake() async {
    // quick horizontal shake
    final e = SequenceEffect([
      MoveByEffect(Vector2(8, 0), EffectController(duration: 0.04)),
      MoveByEffect(Vector2(-16, 0), EffectController(duration: 0.08)),
      MoveByEffect(Vector2(8, 0), EffectController(duration: 0.04)),
    ]);
    await add(e);
  }


  Future<void> bounce() async {
    final up = MoveByEffect(Vector2(0, -10), EffectController(duration: 0.08));
    final down = MoveByEffect(Vector2(0, 10), EffectController(duration: 0.10));
    await add(SequenceEffect([up, down]));
  }

  Color _colorFor(LetterStatus s) {
    switch (s) {
      case LetterStatus.correct:
        return const Color(0xFF6AAA64);
      case LetterStatus.present:
        return const Color(0xFFC9B458);
      case LetterStatus.absent:
        return const Color(0xFF787C7E);
      case LetterStatus.unknown:
        return const Color(0xFF3A3A3C);
    }
  }
}