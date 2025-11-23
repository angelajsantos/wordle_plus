/// MODES SCREEN:
///   modes screen that has
///   - list of all modes
///   TODO: fix ui styling

import 'package:flutter/material.dart';
import '../../core/models/game_mode.dart';
import 'game_screen.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final modes = GameMode.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modes'),
        centerTitle: true,
        backgroundColor: const Color(0xFF121213),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final mode = modes[i];
              return ListTile(
                title: Text(mode.label),
                subtitle: Text(mode.description),
                trailing: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(mode: mode),
                      ),
                    );
                  },
                  child: const Text('Play'),
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: modes.length,
          ),
        ),
      ),
    );
  }
}