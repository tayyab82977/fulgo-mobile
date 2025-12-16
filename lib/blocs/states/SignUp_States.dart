import 'package:equatable/equatable.dart';
import 'package:xturbox/blocs/events/SignUp_Events.dart';

abstract class SignUpStates extends Equatable {

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpStates {}

class SignUpLoading extends SignUpStates {}
class ApplicationUpdated extends SignUpStates {}
class InValidToken extends SignUpStates {}
class SignUpSuccess extends SignUpStates {}
class SignUpSuccessApproved extends SignUpStates {}

class SignUpFailure extends SignUpStates {
  String? error ;
  SignUpEvents? failedEvents;
  final List<String?>? errors;
  SignUpFailure({this.errors , this.error,this.failedEvents});

  @override
  List<Object?> get props => [errors ];

}