/// HUD OVERLAY:
///   on-screen keyboard widget and connection to actual keyboard

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/letter_status.dart';
import '../theme/retro_theme.dart';

typedef OnKey = void Function(String key);

class HudOverlay extends StatefulWidget {
  final OnKey onKey;
  final Map<String, LetterStatus> keyStatuses;

  const HudOverlay({
    super.key,
    required this.onKey,
    required this.keyStatuses,
  });

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  final FocusNode _focusNode = FocusNode();
  final Set<String> _pressed = {};

  @override
  void initState() {
    super.initState();
    // ensure we get focus when built
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color _bgFor(String ch) {
    final status = widget.keyStatuses[ch] ?? LetterStatus.unknown;
    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF6AAA64);
      case LetterStatus.present:
        return const Color(0xFFC9B458);
      case LetterStatus.absent:
        return const Color(0xFF2A2A34);
      case LetterStatus.unknown:
        return const Color(0xFF787C7E);
    }
  }

  // physical keyboard handler
  void _handlePhysicalKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    String? mapped;
    final label = event.logicalKey.keyLabel.toUpperCase();

    if (label.length == 1 && RegExp(r'^[A-Z]$').hasMatch(label)) {
      mapped = label;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      mapped = '<';
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      mapped = '>';
    }

    if (mapped != null) {
      _pressVisual(mapped);
      widget.onKey(mapped);
    }
  }

  // visual press effect
  void _pressVisual(String ch) {
    setState(() => _pressed.add(ch));
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _pressed.remove(ch));
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      '<ZXCVBNM>', // < = enter, > = backspace
    ];

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handlePhysicalKey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
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
                          child: GestureDetector(
                            onTapDown: (_) {
                              _pressVisual(ch);
                              widget.onKey(ch);
                              _focusNode.requestFocus();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: _pressed.contains(ch)
                                    ? RetroTheme.border
                                    : _bgFor(ch),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: RetroTheme.border,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              width: ch == '<' ? 72 : 36,
                              height: 40,
                              child: Text(
                                ch == '<'
                                    ? 'ENTER'
                                    : ch == '>'
                                        ? '⌫'
                                        : ch,
                                style: RetroTheme.button.copyWith(
                                  fontSize: ch == '<' ? 10 : 11,
                                  color: RetroTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
