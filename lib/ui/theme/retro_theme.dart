import 'package:flutter/material.dart';

class RetroTheme {
  // colors
  static const Color bg = Color(0xFF050608);
  static const Color surface = Color(0xFF15151B);
  static const Color border = Color(0xFF31313F);
  static const Color accent = Color(0xFF66BB6A); // green
  static const Color accentAlt = Color(0xFF80CBC4); // teal
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9E9E9E);

  static const String pixelFont = 'PressStart2P';

  // text styles
  static const TextStyle logo = TextStyle(
    fontFamily: pixelFont,
    fontSize: 26,
    letterSpacing: 4,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: pixelFont,
    fontSize: 18,
    letterSpacing: 2,
    color: textPrimary,
  );

  static const TextStyle section = TextStyle(
    fontFamily: pixelFont,
    fontSize: 12,
    letterSpacing: 2,
    color: textMuted,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: pixelFont,
    fontSize: 12,
    letterSpacing: 2,
    color: textPrimary,
  );
}

/// blocky "pixel" style button used across screens.
class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final EdgeInsets padding;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = primary ? RetroTheme.accent : Colors.transparent;
    final textColor = primary ? Colors.black : RetroTheme.textPrimary;

    return InkWell(
      onTap: onPressed,
      splashColor: RetroTheme.accent.withOpacity(0.2),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: RetroTheme.border, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label.toUpperCase(),
          style: RetroTheme.button.copyWith(color: textColor),
        ),
      ),
    );
  }
}
