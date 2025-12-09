import 'dart:async';

class EventBus {
  final _controller = StreamController<Map<String, Object?>>.broadcast();
  Stream<Map<String, Object?>> get stream => _controller.stream;
  void emit(String type, [Map<String, Object?> data = const {}]) =>
      _controller.add({'type': type, ...data});
  void dispose() => _controller.close();
}