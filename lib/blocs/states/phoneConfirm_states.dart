abstract class PhoneConfirmStates {}


class PhoneConfirmInitial extends PhoneConfirmStates {}
class PhoneConfirmLoading extends PhoneConfirmStates {}
class PhoneConfirmSuccess extends PhoneConfirmStates {}
class CodeSendingSuccess extends PhoneConfirmStates {}
class ApplicationUpdated extends PhoneConfirmStates {}
class InValidToken extends PhoneConfirmStates {}

class PhoneConfirmError extends PhoneConfirmStates {
  String? error ;
  PhoneConfirmError({this.error});
}

class CodeSendingError extends PhoneConfirmStates {
  String? error ;
  CodeSendingError({this.error});
}

class FailedToLogin extends PhoneConfirmStates {}