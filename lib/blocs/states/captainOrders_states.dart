import 'package:xturbox/blocs/events/captainOrders_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/newForCaptainOrders.dart';

abstract class CaptainOrdersStates {}


class CaptainOrdersInitial extends CaptainOrdersStates{}
class CaptainOrdersLoading extends CaptainOrdersStates{}
class ApplicationUpdated extends CaptainOrdersStates{}
class InValidToken extends CaptainOrdersStates{}
class CaptainOrdersEmpty extends CaptainOrdersStates{
  CaptainOrdersEvents? refresh ;
  CaptainOrdersEmpty({this.refresh});

}
class CaptainOrdersLoaded extends CaptainOrdersStates{
  CapOrdersDataModel? newForCapOrders ;

  CaptainOrdersLoaded({this.newForCapOrders});
}
class CaptainOrdersError extends CaptainOrdersStates{

  CaptainOrdersEvents? failedEvent ;
  String? error ;

  CaptainOrdersError({this.failedEvent , this.error});
}