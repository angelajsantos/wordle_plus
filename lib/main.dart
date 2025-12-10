import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/services/word_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final wordService = await WordService.loadFromAssets();

  runApp(
    buildAppWithProviders(
      wordService: wordService,
      child: const WordleApp(),
    ),
  );
}
