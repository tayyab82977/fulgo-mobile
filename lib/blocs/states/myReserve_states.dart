import 'package:xturbox/blocs/events/myReserve_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';

abstract class MyReservesStates {}


class MyReservesInitial extends MyReservesStates {}
class MyReservesLoading extends MyReservesStates {}
class ApplicationUpdated extends MyReservesStates {}
class InValidToken extends MyReservesStates {}
class MyReservesLoaded extends MyReservesStates {
  List<OrdersDataModelMix>? ordersList ;

  MyReservesLoaded({this.ordersList});

}
class MyReservesEmpty extends MyReservesStates {}
class MyReservesFailure extends MyReservesStates {
  MyReservesEvents? failedEvent ;
  String? error ;

  MyReservesFailure({this.failedEvent,this.error});
}