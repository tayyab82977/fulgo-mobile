import 'package:xturbox/blocs/events/clientPayments_events.dart';
import 'package:xturbox/data_providers/models/PaymentsAndProfile.dart';
import 'package:xturbox/data_providers/models/clientPaymentsDataModel.dart';

abstract class ClientPaymentsStates {}


class ClientPaymentsInitial extends ClientPaymentsStates {}
class ClientPaymentsLoading extends ClientPaymentsStates {}
class ApplicationUpdated extends ClientPaymentsStates {}
class InValidToken extends ClientPaymentsStates {}
class ClientPaymentsLoaded extends ClientPaymentsStates {
  PaymentsAndProfile? paymentsAndProfile ;
  ClientPaymentsLoaded({this.paymentsAndProfile});
}
class ClientPaymentsError extends ClientPaymentsStates {
  ClientPaymentsEvents? failedEvent ;
 String? error ;
  ClientPaymentsError({this.failedEvent,this.error});
}