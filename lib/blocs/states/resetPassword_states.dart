abstract class ResetPasswordStates {}


class ResetPasswordInitial extends ResetPasswordStates {}
class ResetPasswordLoading extends ResetPasswordStates {}
class ResetPasswordCodeSent extends ResetPasswordStates {}
class ResetPasswordPasswordChanged extends ResetPasswordStates {}
class ResetPasswordPasswordSemiChanged extends ResetPasswordStates {}
class ResetPasswordError extends ResetPasswordStates {
  String? error ;
  List<String?>? errorList ;
  ResetPasswordError({this.error , this.errorList});
}