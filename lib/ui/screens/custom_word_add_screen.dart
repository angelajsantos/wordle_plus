import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/custom_word_service.dart';
import '../theme/retro_theme.dart';
import '../../ui/messages/retro_message.dart';

class CustomWordAddScreen extends StatefulWidget {
  const CustomWordAddScreen({super.key});

  @override
  State<CustomWordAddScreen> createState() => _CustomWordAddScreenState();
}

class _CustomWordAddScreenState extends State<CustomWordAddScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _showRetroMessage(String message, {Color? bgColor}) {
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

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  Future<void> _loadWords() async {
    final svc = context.read<CustomWordService>();
    final loaded = await svc.getWords();
    setState(() => _words = loaded);
  }

  Future<void> _addWord() async {
    final svc = context.read<CustomWordService>();
    final input = _controller.text.trim().toUpperCase();

    if (!RegExp(r'^[A-Z]{5}$').hasMatch(input)) {
      RetroMessage.show(context, 'Word must be exactly 5 letters A–Z');
      return;
    }

    setState(() => _loading = true);
    try {
      await svc.addWord(input);
      _controller.clear();
      FocusScope.of(context).unfocus();
      RetroMessage.show(context, 'Added "$input"');
      await _loadWords(); // refresh the list
    } catch (e) {
      RetroMessage.show(context, (e.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeWord(String w) async {
    final svc = context.read<CustomWordService>();
    await svc.removeWord(w);
    await _loadWords(); // refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroTheme.bg,
      appBar: AppBar(
        backgroundColor: RetroTheme.bg,
        elevation: 0,
        centerTitle: true,
        title: const Text("CUSTOM WORD BANK", style: RetroTheme.title),
        iconTheme: const IconThemeData(color: RetroTheme.textPrimary),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // INPUT BLOCK
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RetroTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: RetroTheme.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "ADD A 5-LETTER WORD",
                        style: RetroTheme.section.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLength: 5,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontSize: 20,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RetroTheme.bg,
                          counterText: "",
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: RetroTheme.border, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: RetroTheme.accent, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _loading ? null : _addWord,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          decoration: BoxDecoration(
                            color: RetroTheme.accent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: RetroTheme.border, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _loading ? "..." : "ADD WORD",
                              style: RetroTheme.title.copyWith(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // WORD LIST
                Expanded(
                  child: _words.isEmpty
                      ? Text("NO CUSTOM WORDS ADDED", style: RetroTheme.section)
                      : ListView.separated(
                    itemCount: _words.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final w = _words[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: RetroTheme.surface,
                          border: Border.all(
                              color: RetroTheme.border, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                w,
                                style: RetroTheme.title.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeWord(w),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}