import 'package:xturbox/blocs/events/pickup_evevnts.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/memberBalanceModel.dart';
import 'package:xturbox/data_providers/models/pickupReportModel.dart';

abstract class PickUpStates {}

class PickupInitial extends PickUpStates {}

class PickupLoading extends PickUpStates {}

class ApplicationUpdated extends PickUpStates {}

class InValidToken extends PickUpStates {}

class PickupSuccess extends PickUpStates {
  PickupReportModel? pickupReport;
  PickupSuccess({this.pickupReport});
}

class PickupFailure extends PickUpStates {
  String? error;
  List<String>? errorList;
  PickUpEvents? failedEvent;

  PickupFailure({this.error, this.failedEvent,this.errorList});
}

class ReceiptLoaded extends PickUpStates {
  String? receipt ;
  ReceiptLoaded({this.receipt});

}
class ClientBalanceLoading extends PickUpStates {}

class ClientCreditLoading extends PickUpStates {}

class MsgSentSuccessfully extends PickUpStates {}


class ClientCreditSuccess extends PickUpStates {
  List<String>? calculations;
  ClientCreditSuccess({this.calculations});
}

class ClientCreditFailure extends PickUpStates {
  String? error;
  PickUpEvents? failedEvent;
  List<String?>? errorList;

  ClientCreditFailure({this.error, this.failedEvent, this.errorList});
}
