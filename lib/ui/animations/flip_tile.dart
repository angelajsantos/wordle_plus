/// FLIP TILE:
///   flutter tile flip animation

import 'package:flutter/material.dart';
import '../../core/models/letter_status.dart';

class AnimatedFlipTile extends StatefulWidget {
  final String letter;
  final LetterStatus status;
  final double size;
  final int flipDelayMs;

  const AnimatedFlipTile({
    super.key,
    required this.letter,
    required this.status,
    required this.size,
    this.flipDelayMs = 0,
  });

  @override
  State<AnimatedFlipTile> createState() => _AnimatedFlipTileState();
}

class _AnimatedFlipTileState extends State<AnimatedFlipTile>
    with SingleTickerProviderStateMixin {
  late LetterStatus _lastStatus;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _lastStatus = widget.status;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1, // start fully visible
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedFlipTile old) {
    super.didUpdateWidget(old);
    if (old.status == LetterStatus.unknown &&
        widget.status != LetterStatus.unknown) {
      // triggers one flip per reveal
      Future.delayed(Duration(milliseconds: widget.flipDelayMs), () async {
        if (!mounted) return;
        await _ctrl.reverse(from: 1);
        setState(() => _lastStatus = widget.status); // swap face
        await _ctrl.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _bg(LetterStatus s) {
    switch (s) {
      case LetterStatus.correct: return const Color(0xFF6AAA64);
      case LetterStatus.present: return const Color(0xFFC9B458);
      case LetterStatus.absent:  return const Color(0xFF3A3A3C);
      case LetterStatus.unknown: return const Color(0xFF787C7E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scaleY = _ctrl.value.clamp(0.01, 1.0);
        return Transform.scale(
          scaleY: scaleY,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bg(_lastStatus),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}