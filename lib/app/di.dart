/// Dependency Injection:
///   potential use for simple dependency registration / service locator
///   example:
///   - provide WordService, ProgressService, etc. to widgets

import 'package:provider/provider.dart';
import '../core/services/word_service.dart';
import '../core/services/progress_service.dart';
import '../core/services/achievement_service.dart';


List<Provider> buildProviders() {
// Load word lists (you can move to asset loading async on splash)
  final allowed = <String>{/* load asset text into set */};
  final answers = <String>[/* load answers */];


  return [
    Provider(create: (_) => WordService(allowed: allowed, answers: answers)),
    Provider(create: (_) => ProgressService()),
    Provider<AchievementService>(create: (_) => NoopAchievementService()),
  ];
}