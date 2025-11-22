/// HUD OVERLAY:
///   on-screen keyboard widget
///   FIXME: add connection to actual keyboard

import 'package:flutter/material.dart';

typedef OnKey = void Function(String key);

class HudOverlay extends StatelessWidget {
  final OnKey onKey;
  const HudOverlay({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      '<ZXCVBNM>' // < = backspace, > = enter
    ];
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final ch in row.split(''))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ElevatedButton(
                        onPressed: () => onKey(ch),
                        child: Text(ch == '<' ? '⌫' : ch == '>' ? 'ENTER' : ch),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}