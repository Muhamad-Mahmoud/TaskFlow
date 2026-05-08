import 'dart:async';

enum AuthEvent { loggedOut }

class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _controller.stream;

  void emit(AuthEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

