abstract class CaptainCancelClientStates {}


class CaptainCancelClientInitial extends CaptainCancelClientStates {}
class CaptainCancelClientLoading extends CaptainCancelClientStates {}
class CaptainCancelClientSuccess extends CaptainCancelClientStates {}
class CaptainCancelClientFailed extends CaptainCancelClientStates {
  String? error ;
  CaptainCancelClientFailed({this.error});
}
class ApplicationUpdated extends CaptainCancelClientStates {}
class InValidToken extends CaptainCancelClientStates {}