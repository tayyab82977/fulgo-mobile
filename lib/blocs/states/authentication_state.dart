import 'package:equatable/equatable.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {
  ResourcesData? resourcesData ;

  AuthenticationUninitialized({this.resourcesData});
}

class AuthenticationAuthenticated extends AuthenticationState {
  ResourcesData? resourcesData ;
  AuthenticationAuthenticated({this.resourcesData});
}

class AuthenticationUnauthenticated extends AuthenticationState {
  ResourcesData? resourcesData ;
  AuthenticationUnauthenticated({this.resourcesData});
}

class AuthenticationLoading extends AuthenticationState {
  ResourcesData? resourcesData ;
  AuthenticationLoading({this.resourcesData});
}


class AuthenticationError extends AuthenticationState {

  ResourcesData? resourcesData ;
  AuthenticationEvent? failedEvent ;
  String? error ;

  AuthenticationError({this.failedEvent , this.resourcesData , this.error});

}

class AuthenticationUpdate extends AuthenticationState {
  ResourcesData? resourcesData ;

  AuthenticationUpdate({this.resourcesData});
}

class AnimationState extends AuthenticationState {}
