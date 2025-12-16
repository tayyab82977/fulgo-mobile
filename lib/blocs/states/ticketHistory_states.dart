
import 'package:xturbox/data_providers/models/tickets_model.dart';

abstract class TicketsHistoryStates {}


class TicketsHistoryInitial extends TicketsHistoryStates {}
class TicketsHistoryLoading extends TicketsHistoryStates {}
class TicketsHistoryLoaded extends TicketsHistoryStates {
  List <TicketsHistoryModel>? list ;
  TicketsHistoryLoaded({this.list});
}
class TicketsHistoryError extends TicketsHistoryStates {
  String? error ;
  TicketsHistoryError({this.error});
}
