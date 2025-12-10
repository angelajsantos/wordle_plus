/// Dependency Injection:
///   potential use for simple dependency registration / service locator
///   example:
///   - provide WordService, ProgressService, etc. to widgets

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/services/word_service.dart';
import '../core/services/progress_service.dart';
import '../core/services/achievement_service.dart';
import '../core/services/custom_word_service.dart';
import '../core/services/hint_service.dart';

List<SingleChildWidget> buildProviders(WordService wordService) {
  return [
    Provider<WordService>.value(value: wordService),
    Provider(create: (_) => ProgressService()),
    Provider<AchievementService>(create: (_) => NoopAchievementService()),
    Provider<CustomWordService>(create: (_) => CustomWordService()),
    ChangeNotifierProvider(create: (_) => HintService()),
  ];
}

Widget buildAppWithProviders({
  required WordService wordService,
  required Widget child,
}) {
  return MultiProvider(
    providers: buildProviders(wordService),
    child: child,
  );
}
