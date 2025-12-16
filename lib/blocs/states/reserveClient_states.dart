import 'package:xturbox/blocs/events/reserveClient_events.dart';

abstract class ReserveClientStates {}


class ReserveClientInitial extends ReserveClientStates {}
class ReserveClientLoading extends ReserveClientStates {}
class ReserveClientSuccess extends ReserveClientStates {}
class ApplicationUpdated   extends ReserveClientStates {}
class RecordedPickupIssueSuccess extends ReserveClientStates {}
class CancelClientSuccess extends ReserveClientStates {}
class InValidToken extends ReserveClientStates {}
class ReserveClientFailure extends ReserveClientStates {
  ReserveClientEvents? failedEvent ;
  String? error ;
  List<String?>? errorList ;
  ReserveClientFailure({this.failedEvent,this.error , this.errorList});
}
class CancelClientFailure extends ReserveClientStates {
  ReserveClientEvents? failedEvent ;
  String? error ;
  List<String?>? errorList ;
  CancelClientFailure({this.failedEvent,this.error,this.errorList});
}