/// ROW EFFECTS:
///   flutter row effects. applies shakes and bounce.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class RowEffects extends StatefulWidget {
  final Widget child;
  final bool shake;           // true to shake
  final bool bounce;          // true to bounce
  final int shakeTrigger;     // bump value to retrigger shake
  final int bounceTrigger;    // bump value to retrigger bounce

  const RowEffects({
    super.key,
    required this.child,
    required this.shake,
    required this.bounce,
    required this.shakeTrigger,
    required this.bounceTrigger,
  });

  @override
  State<RowEffects> createState() => _RowEffectsState();
}

class _RowEffectsState extends State<RowEffects>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final AnimationController _bounce;

  int _lastShakeTrigger = 0;
  int _lastBounceTrigger = 0;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
  }

  @override
  void didUpdateWidget(covariant RowEffects oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shake && widget.shakeTrigger != _lastShakeTrigger) {
      _lastShakeTrigger = widget.shakeTrigger;
      _shake.forward(from: 0);
    }
    if (widget.bounce && widget.bounceTrigger != _lastBounceTrigger) {
      _lastBounceTrigger = widget.bounceTrigger;
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget w = AnimatedBuilder(
      animation: _shake,
      builder: (_, child) {
        final t = _shake.value; // 0..1
        final dx = math.sin(t * math.pi * 4) * 6; // 2 cycles
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );

    w = AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) {
        final t = _bounce.value; // 0..1
        final dy = -8 * math.sin(t * math.pi); // up & down
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: w,
    );

    return w;
  }
}