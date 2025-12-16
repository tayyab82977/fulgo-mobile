import 'package:xturbox/blocs/events/myPickup_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/pickUpDataModel.dart';

abstract class MyPickupStates {}


class MyPickupInitial extends MyPickupStates {}
class MyPickupLoading extends MyPickupStates {}
class BulkSoreOutSuccess extends MyPickupStates {}

class MyPickupLoaded extends MyPickupStates {
  PickUpDataModel? pickUpDataModel ;
  MyPickupLoaded({this.pickUpDataModel});

}
class MyPickupError extends MyPickupStates {
  MyPickupEvents? failedEvents ;
  String? error ;
  List<String>? errorsList ;

  MyPickupError({this.failedEvents,this.error , this.errorsList});
}

class BulkStoreOutErrorError extends MyPickupStates {
  MyPickupEvents? failedEvents ;
  String? error ;
  List<String?>? errorsList ;

  BulkStoreOutErrorError({this.failedEvents,this.error , this.errorsList});
}