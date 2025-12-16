abstract class NationalIdStates {}


class NationalIdInitial extends NationalIdStates {}
class NationalIdLoading extends NationalIdStates {}

class NationalIdSetSuccess extends NationalIdStates {}
class NationalIdError extends NationalIdStates {
  List<String>? errorList ;
  String? error;
  NationalIdError({this.errorList , this.error});
}