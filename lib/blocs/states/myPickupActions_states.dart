abstract class PickupActionsStates {}

class PickupActionsInitial extends PickupActionsStates {}

class PickupActionsLoading extends PickupActionsStates {}

class PickupActionsFailure extends PickupActionsStates {
  String? error;
  List<String?>? errorList;
  PickupActionsFailure({this.error, this.errorList});
}

class PickupActionSuccess extends PickupActionsStates {}
class PickupReActiveSuccess extends PickupActionsStates {}
class ReceiptLoadedSuccess extends PickupActionsStates {
  String? receipt ;
  ReceiptLoadedSuccess({this.receipt});
}
class MsgSentSuccessfully extends PickupActionsStates {}

class ApplicationUpdated extends PickupActionsStates {}
class NoCallNoCancel extends PickupActionsStates {}
class ContactPrmNotGranted extends PickupActionsStates {}

class InValidToken extends PickupActionsStates {}

class PickupActionSoreOutSuccess extends PickupActionsStates {}

class PickupActionDispatchIssueSuccess extends PickupActionsStates {}
