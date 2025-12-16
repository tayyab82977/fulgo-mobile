import 'package:xturbox/blocs/events/odoMeter_events.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class ODOMeterStates {}


class ODOMeterInitial extends ODOMeterStates {}
class ODOMeterLoading extends ODOMeterStates {}

class ODOMeterSetSuccess extends ODOMeterStates {
  Meter meter ;
  ODOMeterSetSuccess({required this.meter});
}
class ODOMeterError extends ODOMeterStates {
  ODOMeterEvents? failedEvent ;
  List<String>? errorList ;
  String? error;
  ODOMeterError({this.failedEvent,this.errorList , this.error});
}