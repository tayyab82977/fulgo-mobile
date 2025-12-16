

abstract class AddAccountStates {}


class AddAccountInitial extends AddAccountStates {}
class AddAccountLoading extends AddAccountStates {}

class AddAccountSetSuccess extends AddAccountStates {}
class AddAccountError extends AddAccountStates {
  List<String>? errorList ;
  String? error;
  AddAccountError({this.errorList , this.error});
}