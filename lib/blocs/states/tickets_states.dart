

import 'package:xturbox/blocs/events/tickets_events.dart';
import 'package:xturbox/data_providers/models/tickets_model.dart';

abstract class TicketsStates {}


class TicketsInitial extends TicketsStates{}
class TicketsLoading extends TicketsStates{}

class TicketsLoaded extends TicketsStates{
  List<TicketsModel> ticketsList ;
  TicketsLoaded({required this.ticketsList});
}
class TicketsAddSuccess extends TicketsStates{}
class TicketsError extends TicketsStates{

  TicketsEvents? failedEvent ;
  String? error ;

  TicketsError({this.failedEvent , this.error});
}