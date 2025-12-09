import 'package:flutter/material.dart';
import '../../ui/theme/retro_theme.dart';

class RetroMessage {
  static void show(
      BuildContext context,
      String message, {
        Color? bgColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    final color = bgColor ?? RetroTheme.surface;
    final overlay = Overlay.of(context);


    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 24,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: RetroTheme.border, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message,
              style: RetroTheme.title.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}