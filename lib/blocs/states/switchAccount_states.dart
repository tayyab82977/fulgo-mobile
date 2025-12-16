

abstract class SwitchAccountStates {}


class SwitchAccountInitial extends SwitchAccountStates {}
class SwitchAccountLoading extends SwitchAccountStates {}

class SwitchAccountSetSuccess extends SwitchAccountStates {}
class SwitchAccountError extends SwitchAccountStates {
  List<String>? errorList ;
  String? error;
  SwitchAccountError({this.errorList , this.error});
}