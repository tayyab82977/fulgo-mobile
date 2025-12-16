import 'package:xturbox/blocs/events/bulkPickup_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/memberBalanceModel.dart';
import 'package:xturbox/data_providers/models/pickupReportModel.dart';

abstract class BulkPickupStates {}


class BulkPickupInitial extends BulkPickupStates {}
class BulkPickupLoading extends BulkPickupStates {}
class InValidToken extends BulkPickupStates {}
class BulkPickupSuccess extends BulkPickupStates {
  PickupReportModel? pickupReport ;
  BulkPickupSuccess({this.pickupReport});
}
class ReturnShipmentsSuccess extends BulkPickupStates {}
class BulkPickupFailure extends BulkPickupStates {
  String? error ;
  BulkPickupEvents? failedEvent ;
  List<String?>? errorList;

  BulkPickupFailure({this.error,this.failedEvent,this.errorList});

}
class NewShipmentLoaded extends BulkPickupStates {

 OrdersDataModelMix? ordersDataModelMix ;
  NewShipmentLoaded({this.ordersDataModelMix});

}

class ClientCreditLoading extends BulkPickupStates {}

class MsgSentSuccessfully extends BulkPickupStates {}

class ClientCreditSuccess extends BulkPickupStates {
  List<String>? calculations ;
  ClientCreditSuccess({this.calculations});
}
class ClientCreditFailure extends BulkPickupStates {
  String? error ;
  BulkPickupEvents? failedEvent ;
  List<String?>? errorList;

  ClientCreditFailure({this.error , this.failedEvent,this.errorList});
}

class NewShipmentFailure extends BulkPickupStates {
  String? error ;
  BulkPickupEvents? failedEvent ;
  List<String?>? errorList;

  NewShipmentFailure({this.error , this.failedEvent,this.errorList});
}
class ReceiptLoaded extends BulkPickupStates {
  String? receipt ;
  ReceiptLoaded({this.receipt});

}