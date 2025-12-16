

abstract class AuthenticationEvent{}

class AppStarted extends AuthenticationEvent {}
class Decision extends AuthenticationEvent {}


class LoggedIn extends AuthenticationEvent {
  final String? token;

  LoggedIn({required this.token});

}

class LoggedOut extends AuthenticationEvent {}