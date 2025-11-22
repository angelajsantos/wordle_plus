/// Achievement Service:
///   FIXME: unlock/achievements logic

abstract class AchievementService {
  Future<void> onEvent(String event, Map<String, Object?> payload);
}


class NoopAchievementService implements AchievementService {
  @override
  Future<void> onEvent(String event, Map<String, Object?> payload) async {}
}